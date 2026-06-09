//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import Foundation
import Observation
import Combine
import Domain

@Observable
final class GameViewModel {
    private(set) var timeCount: Double = 30.00
    private(set) var currentWeapon: CurrentWeapon?
    
    var isTutorialViewPresented = false
    var isWeaponSelectViewPresented = false
    var isResultViewPresented = false
    var isWeaponChangeButtonEnabled = false

    private let arShootingLibHandler: ARShootingLibHandlerInterface
    private let soundPlayer: SoundPlayerInterface
    private let tutorialRepository: TutorialRepositoryInterface
    private let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface
    private let gameTimerCreateUseCase: GameTimerCreateUseCaseInterface
    private let weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface
    private let weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    private let timerPauseController = GameTimerCreateRequest.PauseController()
    private let weaponReloadCanceller = WeaponReloadCanceller()
    
    @ObservationIgnored private(set) var score: Double = 0
    @ObservationIgnored private var isCheckedTutorialCompletedFlag = false
    @ObservationIgnored private var reloadingMotionDetecedCount: Int = 0
    
    // MARK: ユニットテスト時のみアクセスする
//    #if TEST
    func setCurrentWeapon(_ currentWeapon: CurrentWeapon?) {
        self.currentWeapon = currentWeapon
    }
//    #endif
    
    init(
        arShootingLibHandler: ARShootingLibHandlerInterface,
        soundPlayer: SoundPlayerInterface,
        tutorialRepository: TutorialRepositoryInterface,
        weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface,
        gameTimerCreateUseCase: GameTimerCreateUseCaseInterface,
        weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface,
        weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    ) {
        self.arShootingLibHandler = arShootingLibHandler
        self.soundPlayer = soundPlayer
        self.tutorialRepository = tutorialRepository
        self.weaponControlMotionHandleUseCase = weaponControlMotionHandleUseCase
        self.gameTimerCreateUseCase = gameTimerCreateUseCase
        self.weaponResourceGetUseCase = weaponResourceGetUseCase
        self.weaponActionExecuteUseCase = weaponActionExecuteUseCase
    }
    
    // MARK: ViewからのInput
    func onViewAppear() {
        let selectedWeapon = weaponResourceGetUseCase.getDefaultWeapon()
        showSelectedWeapon(selectedWeapon)
        
        arShootingLibHandler.runSession()
        
        if !isCheckedTutorialCompletedFlag {
            isCheckedTutorialCompletedFlag = true
            
            let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
            if isTutorialCompleted {
                waitAndCreateTimer()
            }else {
                isTutorialViewPresented = true
            }
        }
    }
    
    func onViewDisappear() {
        arShootingLibHandler.pauseSession()
    }
    
    func tutorialEnded() {
        tutorialRepository.updateTutorialCompletedFlag(isCompleted: true)
        waitAndCreateTimer()
    }
    
    func weaponChangeButtonTapped() {
        // 武器選択中はタイムカウントの更新を止める
        timerPauseController.isPaused = true
        isWeaponSelectViewPresented = true
    }
    
    func weaponSelected(weaponId: Int) {
        // タイムカウントの更新を再開する
        timerPauseController.isPaused = false
        // 既存のリロードをキャンセルする
        weaponReloadCanceller.isCancelled = true
        
        let selectedWeapon = weaponResourceGetUseCase.getWeapon(of: weaponId)
        showSelectedWeapon(selectedWeapon)
    }
    
    // MARK: Privateメソッド
    private func showSelectedWeapon(_ selectedWeapon: CurrentWeapon) {
        self.currentWeapon = selectedWeapon
        
        guard let currentWeapon = self.currentWeapon else { return }
        
        arShootingLibHandler.showWeapon(of: currentWeapon.weapon.id)
        
        if isCheckedTutorialCompletedFlag {
            soundPlayer.play(currentWeapon.weapon.resources.appearingSound)
        }
    }
    
    private func waitAndCreateTimer() {
        guard let currentWeapon = self.currentWeapon else { return }
        
        soundPlayer.play(currentWeapon.weapon.resources.appearingSound)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let request = GameTimerCreateRequest(
                initialTimeCount: self.timeCount,
                updateInterval: 0.01,
                pauseController: self.timerPauseController
            )
            self.gameTimerCreateUseCase.execute(
                request: request,
                onTimerStarted: { [weak self] response in
                    self?.soundPlayer.play(response.startWhistleSound)
                    self?.weaponControlMotionHandleUseCase.startDetection()
                    self?.isWeaponChangeButtonEnabled = true
                },
                onTimerUpdated: { [weak self] response in
                    self?.timeCount = response.timeCount
                },
                onTimerEnded: { [weak self] response in
                    self?.soundPlayer.play(response.endWhistleSound)
                    self?.weaponControlMotionHandleUseCase.stopDetection()
                    self?.isWeaponChangeButtonEnabled = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self?.soundPlayer.play(response.rankingAppearSound)
                        self?.isResultViewPresented = true
                    })
                })
        })
    }
    
    private func fireWeapon() {
        guard let currentWeapon = self.currentWeapon else { return }
        
        weaponActionExecuteUseCase.fireWeapon(
            bulletsCount: currentWeapon.state.bulletsCount,
            isReloading: currentWeapon.state.isReloading,
            reloadType: currentWeapon.weapon.spec.reloadType,
            onFired: { [weak self] response in
                self?.currentWeapon?.state.bulletsCount = response.bulletsCount
                self?.arShootingLibHandler.renderWeaponFiring()
                self?.soundPlayer.play(currentWeapon.weapon.resources.firingSound)
                
                if response.needsAutoReload {
                    // リロードを自動的に実行
                    self?.reloadingMotionDetected()
                }
            },
            onOutOfBullets: { [weak self] in
                if let outOfBulletsSound = currentWeapon.weapon.resources.outOfBulletsSound {
                    self?.soundPlayer.play(outOfBulletsSound)
                }
            })
    }
    
    private func reloadWeapon() {
        guard let currentWeapon = self.currentWeapon else { return }
        
        // falseにリセット
        weaponReloadCanceller.isCancelled = false
        
        weaponActionExecuteUseCase.reloadWeapon(
            bulletsCount: currentWeapon.state.bulletsCount,
            isReloading: currentWeapon.state.isReloading,
            capacity: currentWeapon.weapon.spec.capacity,
            reloadWaitingTime: currentWeapon.weapon.spec.reloadWaitingTime,
            reloadCanceller: weaponReloadCanceller,
            onReloadStarted: { [weak self] response in
                self?.currentWeapon?.state.isReloading = response.isReloading
                self?.soundPlayer.play(currentWeapon.weapon.resources.reloadingSound)
            },
            onReloadEnded: { [weak self] response in
                self?.currentWeapon?.state.bulletsCount = response.bulletsCount
                self?.currentWeapon?.state.isReloading = response.isReloading
            })
    }
}

extension GameViewModel: ARShootingLibHandlerDelegate {
    func targetHit() {
        //ランキングがバラけるように、加算する得点自体に90%~100%の間の乱数を掛ける
        let randomlyAdjustedHitPoint = Double(currentWeapon?.weapon.spec.targetHitPoint ?? 0) * Double.random(in: 0.9...1)
        // 100を超えない様に更新する
        score = min(score + randomlyAdjustedHitPoint, 100.0)
        
        soundPlayer.play(.targetHit)
        
        if let bulletHitSound = currentWeapon?.weapon.resources.bulletHitSound {
            soundPlayer.play(bulletHitSound)
        }
    }
}

extension GameViewModel: WeaponControlMotionHandleUseCaseDelegate {
    func firingMotionDetected() {
        fireWeapon()
    }
    
    func reloadingMotionDetected() {
        reloadWeapon()
        reloadingMotionDetecedCount += 1
        if reloadingMotionDetecedCount == 20 {
            soundPlayer.play(.targetAppearanceChange)
            arShootingLibHandler.changeTargetsAppearance(to: "taimeisan.jpg")
        }
    }
}
