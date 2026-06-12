//
//  GamePresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/06/11.
//

import Foundation
import Domain

protocol GameViewModelInterface: AnyObject {
    var timeCount: Double { get set }
    var currentWeapon: CurrentWeapon? { get set }
    var isTutorialViewPresented: Bool { get set }
    var isWeaponSelectViewPresented: Bool { get set }
    var isResultViewPresented: Bool { get set }
    var isWeaponChangeButtonEnabled: Bool { get set }
    var score: Double { get set }
}

final class GamePresenter<VM: GameViewModelInterface> {
    let viewModel: VM
    
    private let arShootingLibHandler: ARShootingLibHandlerInterface
    private let soundPlayer: SoundPlayerInterface
    private let tutorialRepository: TutorialRepositoryInterface
    private let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface
    private let gameTimerCreateUseCase: GameTimerCreateUseCaseInterface
    private let weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface
    private let weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    
    private let timerPauseController = GameTimerCreateRequest.PauseController()
    private let weaponReloadCanceller = WeaponReloadCanceller()
    
    private var isCheckedTutorialCompletedFlag = false
    private var reloadingMotionDetecedCount: Int = 0
    
    // MARK: ユニットテスト時のみアクセスする
//    #if TEST
    func setCurrentWeapon(_ currentWeapon: CurrentWeapon?) {
        self.viewModel.currentWeapon = currentWeapon
    }
//    #endif
    
    init(
        viewModel: VM,
        arShootingLibHandler: ARShootingLibHandlerInterface,
        soundPlayer: SoundPlayerInterface,
        tutorialRepository: TutorialRepositoryInterface,
        weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface,
        gameTimerCreateUseCase: GameTimerCreateUseCaseInterface,
        weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface,
        weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    ) {
        self.viewModel = viewModel
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
                viewModel.isTutorialViewPresented = true
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
        viewModel.isWeaponSelectViewPresented = true
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
        viewModel.currentWeapon = selectedWeapon
        
        guard let currentWeapon = self.viewModel.currentWeapon else { return }
        
        arShootingLibHandler.showWeapon(of: currentWeapon.weapon.id)
        
        if isCheckedTutorialCompletedFlag {
            soundPlayer.play(currentWeapon.weapon.resources.appearingSound)
        }
    }
    
    private func waitAndCreateTimer() {
        guard let currentWeapon = self.viewModel.currentWeapon else { return }

        soundPlayer.play(currentWeapon.weapon.resources.appearingSound)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let request = GameTimerCreateRequest(
                initialTimeCount: self.viewModel.timeCount,
                updateInterval: 0.01,
                pauseController: self.timerPauseController
            )
            self.gameTimerCreateUseCase.execute(
                request: request,
                onTimerStarted: { [weak self] response in
                    self?.soundPlayer.play(response.startWhistleSound)
                    self?.weaponControlMotionHandleUseCase.startDetection()
                    self?.viewModel.isWeaponChangeButtonEnabled = true
                },
                onTimerUpdated: { [weak self] response in
                    self?.viewModel.timeCount = response.timeCount
                },
                onTimerEnded: { [weak self] response in
                    self?.soundPlayer.play(response.endWhistleSound)
                    self?.weaponControlMotionHandleUseCase.stopDetection()
                    self?.viewModel.isWeaponChangeButtonEnabled = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self?.soundPlayer.play(response.rankingAppearSound)
                        self?.viewModel.isResultViewPresented = true
                    })
                })
        })
    }
    
    private func fireWeapon() {
        guard let currentWeapon = self.viewModel.currentWeapon else { return }

        weaponActionExecuteUseCase.fireWeapon(
            bulletsCount: currentWeapon.state.bulletsCount,
            isReloading: currentWeapon.state.isReloading,
            reloadType: currentWeapon.weapon.spec.reloadType,
            onFired: { [weak self] response in
                self?.viewModel.currentWeapon?.state.bulletsCount = response.bulletsCount
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
        guard let currentWeapon = self.viewModel.currentWeapon else { return }

        // falseにリセット
        weaponReloadCanceller.isCancelled = false
        
        weaponActionExecuteUseCase.reloadWeapon(
            bulletsCount: currentWeapon.state.bulletsCount,
            isReloading: currentWeapon.state.isReloading,
            capacity: currentWeapon.weapon.spec.capacity,
            reloadWaitingTime: currentWeapon.weapon.spec.reloadWaitingTime,
            reloadCanceller: weaponReloadCanceller,
            onReloadStarted: { [weak self] response in
                self?.viewModel.currentWeapon?.state.isReloading = response.isReloading
                self?.soundPlayer.play(currentWeapon.weapon.resources.reloadingSound)
            },
            onReloadEnded: { [weak self] response in
                self?.viewModel.currentWeapon?.state.bulletsCount = response.bulletsCount
                self?.viewModel.currentWeapon?.state.isReloading = response.isReloading
            })
    }
}

extension GamePresenter: ARShootingLibHandlerDelegate {
    func targetHit() {
        //ランキングがバラけるように、加算する得点自体に90%~100%の間の乱数を掛ける
        let randomlyAdjustedHitPoint = Double(viewModel.currentWeapon?.weapon.spec.targetHitPoint ?? 0) * Double.random(in: 0.9...1)
        // 100を超えない様に更新する
        viewModel.score = min(viewModel.score + randomlyAdjustedHitPoint, 100.0)
        
        soundPlayer.play(.targetHit)
        
        if let bulletHitSound = viewModel.currentWeapon?.weapon.resources.bulletHitSound {
            soundPlayer.play(bulletHitSound)
        }
    }
}

extension GamePresenter: WeaponControlMotionHandleUseCaseDelegate {
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
