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
    enum OutputEventType: Equatable {
        case arControllerInputEvent(ARControllerInputEventType)
        case motionDetectorInputEvent(MotionDetectorInputEventType)
        case playSound(SoundType)
        case executeAutoReload
    }
    enum ARControllerInputEventType: Equatable {
        case runSceneSession
        case pauseSceneSession
        case renderWeaponFiring
        case showWeaponObject(weaponId: Int)
        case changeTargetsAppearance(imageName: String)
    }
    enum MotionDetectorInputEventType: Equatable {
        case startDeviceMotionDetection
        case stopDeviceMotionDetection
    }
    
    private(set) var timeCount: Double = 30.00
    private(set) var currentWeapon: CurrentWeapon?
    
    var isTutorialViewPresented = false
    var isWeaponSelectViewPresented = false
    var isResultViewPresented = false
    var isWeaponChangeButtonEnabled = false

    let outputEvent = PassthroughSubject<OutputEventType, Never>()
    
    private let tutorialRepository: TutorialRepositoryInterface
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
        tutorialRepository: TutorialRepositoryInterface,
        gameTimerCreateUseCase: GameTimerCreateUseCaseInterface,
        weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface,
        weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    ) {
        self.tutorialRepository = tutorialRepository
        self.gameTimerCreateUseCase = gameTimerCreateUseCase
        self.weaponResourceGetUseCase = weaponResourceGetUseCase
        self.weaponActionExecuteUseCase = weaponActionExecuteUseCase
    }
    
    // MARK: ViewからのInput
    func onViewAppear() {
        let selectedWeapon = weaponResourceGetUseCase.getDefaultWeapon()
        showSelectedWeapon(selectedWeapon)
        
        outputEvent.send(.arControllerInputEvent(.runSceneSession))
        
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
        outputEvent.send(.arControllerInputEvent(.pauseSceneSession))
    }
    
    func tutorialEnded() {
        tutorialRepository.updateTutorialCompletedFlag(isCompleted: true)
        waitAndCreateTimer()
    }
    
    func fireMotionDetected() {
        fireWeapon()
    }
    
    func reloadMotionDetected() {
        reloadWeapon()
        reloadingMotionDetecedCount += 1
        if reloadingMotionDetecedCount == 20 {
            outputEvent.send(.playSound(.targetAppearanceChange))
            outputEvent.send(.arControllerInputEvent(.changeTargetsAppearance(imageName: "taimeisan.jpg")))
        }
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
    
    func targetHit() {
        //ランキングがバラけるように、加算する得点自体に90%~100%の間の乱数を掛ける
        let randomlyAdjustedHitPoint = Double(currentWeapon?.weapon.spec.targetHitPoint ?? 0) * Double.random(in: 0.9...1)
        // 100を超えない様に更新する
        score = min(score + randomlyAdjustedHitPoint, 100.0)
        
        outputEvent.send(.playSound(.targetHit))
        
        if let bulletHitSound = currentWeapon?.weapon.resources.bulletHitSound {
            outputEvent.send(.playSound(bulletHitSound))
        }
    }
    
    // MARK: Privateメソッド
    private func showSelectedWeapon(_ selectedWeapon: CurrentWeapon) {
        self.currentWeapon = selectedWeapon
        
        guard let currentWeapon = self.currentWeapon else { return }
        
        outputEvent.send(.arControllerInputEvent(.showWeaponObject(weaponId: currentWeapon.weapon.id)))
        
        if isCheckedTutorialCompletedFlag {
            outputEvent.send(.playSound(currentWeapon.weapon.resources.appearingSound))
        }
    }
    
    private func waitAndCreateTimer() {
        guard let currentWeapon = self.currentWeapon else { return }
        
        outputEvent.send(.playSound(currentWeapon.weapon.resources.appearingSound))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let request = GameTimerCreateRequest(
                initialTimeCount: self.timeCount,
                updateInterval: 0.01,
                pauseController: self.timerPauseController
            )
            self.gameTimerCreateUseCase.execute(
                request: request,
                onTimerStarted: { response in
                    self.outputEvent.send(.playSound(response.startWhistleSound))
                    self.outputEvent.send(.motionDetectorInputEvent(.startDeviceMotionDetection))
                    self.isWeaponChangeButtonEnabled = true
                },
                onTimerUpdated: { response in
                    self.timeCount = response.timeCount
                },
                onTimerEnded: { response in
                    self.outputEvent.send(.playSound(response.endWhistleSound))
                    self.outputEvent.send(.motionDetectorInputEvent(.stopDeviceMotionDetection))
                    self.isWeaponChangeButtonEnabled = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self.outputEvent.send(.playSound(response.rankingAppearSound))
                        self.isResultViewPresented = true
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
            onFired: { response in
                self.currentWeapon?.state.bulletsCount = response.bulletsCount
                outputEvent.send(.arControllerInputEvent(.renderWeaponFiring))
                outputEvent.send(.playSound(currentWeapon.weapon.resources.firingSound))
                
                if response.needsAutoReload {
                    // リロードを自動的に実行
                    outputEvent.send(.executeAutoReload)
                }
            },
            onOutOfBullets: {
                if let outOfBulletsSound = currentWeapon.weapon.resources.outOfBulletsSound {
                    outputEvent.send(.playSound(outOfBulletsSound))
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
            onReloadStarted: { response in
                self.currentWeapon?.state.isReloading = response.isReloading
                outputEvent.send(.playSound(currentWeapon.weapon.resources.reloadingSound))
            },
            onReloadEnded: { response in
                self.currentWeapon?.state.bulletsCount = response.bulletsCount
                self.currentWeapon?.state.isReloading = response.isReloading
            })
    }
}
