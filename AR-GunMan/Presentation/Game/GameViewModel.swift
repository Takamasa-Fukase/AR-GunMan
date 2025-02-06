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
    enum ARControllerInputEventType {
        case runSceneSession
        case pauseSceneSession
        case renderWeaponFiring
        case showWeaponObject(weaponId: Int)
        case changeTargetsAppearance(imageName: String)
    }
    enum MotionDetectorInputEventType {
        case startDeviceMotionDetection
        case stopDeviceMotionDetection
    }
    
    private(set) var timeCount: Double = 30.00
    private(set) var currentWeaponData: CurrentWeaponData?
    
    // MARK: ユニットテスト時のみアクセスする
//    #if TEST
    func getCurrentWeaponData() -> CurrentWeaponData? {
        return currentWeaponData
    }
    func setCurrentWeaponData(_ currentWeaponData: CurrentWeaponData?) {
        self.currentWeaponData = currentWeaponData
    }
//    #endif
    
    var isTutorialViewPresented = false
    var isWeaponSelectViewPresented = false
    var isResultViewPresented = false
    var isWeaponChangeButtonEnabled = false
    
    let arControllerInputEvent = PassthroughSubject<ARControllerInputEventType, Never>()
    let motionDetectorInputEvent = PassthroughSubject<MotionDetectorInputEventType, Never>()
    let playSound = PassthroughSubject<SoundType, Never>()
    
    private let tutorialRepository: TutorialRepositoryInterface
    private let gameTimerCreateUseCase: GameTimerCreateUseCaseInterface
    private let weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface
    private let weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    private let timerPauseController = GameTimerCreateRequest.PauseController()
    private let weaponReloadCanceller = WeaponReloadCanceller()

    @ObservationIgnored private(set) var score: Double = 0
    @ObservationIgnored private var isCheckedTutorialCompletedFlag = false
    @ObservationIgnored private var reloadingMotionDetecedCount: Int = 0
    
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
        let selectedWeaponData = weaponResourceGetUseCase.getDefaultWeaponDetail()
        showSelectedWeapon(selectedWeaponData)
        
        arControllerInputEvent.send(.runSceneSession)
        
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
        arControllerInputEvent.send(.pauseSceneSession)
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
            playSound.send(.targetAppearanceChange)
            arControllerInputEvent.send(.changeTargetsAppearance(imageName: "taimeisan.jpg"))
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
        
        let selectedWeaponData = weaponResourceGetUseCase.getWeaponDetail(of: weaponId)
        showSelectedWeapon(selectedWeaponData)
    }
    
    func targetHit() {
        //ランキングがバラけるように、加算する得点自体に90%~100%の間の乱数を掛ける
        let randomlyAdjustedHitPoint = Double(currentWeaponData?.spec.targetHitPoint ?? 0) * Double.random(in: 0.9...1)
        // 100を超えない様に更新する
        score = min(score + randomlyAdjustedHitPoint, 100.0)
        
        playSound.send(.targetHit)
        
        if let bulletHitSound = currentWeaponData?.resources.bulletHitSound {
            playSound.send(bulletHitSound)
        }
    }
    
    // MARK: Privateメソッド
    private func showSelectedWeapon(_ selectedWeaponData: CurrentWeaponData) {
        self.currentWeaponData = selectedWeaponData
        
        guard let currentWeaponData = self.currentWeaponData else { return }
        
        arControllerInputEvent.send(.showWeaponObject(weaponId: currentWeaponData.id))
        
        if isCheckedTutorialCompletedFlag {
            playSound.send(currentWeaponData.resources.appearingSound)
        }
    }
    
    private func waitAndCreateTimer() {
        guard let currentWeaponData = self.currentWeaponData else { return }
        
        playSound.send(currentWeaponData.resources.appearingSound)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let request = GameTimerCreateRequest(
                initialTimeCount: self.timeCount,
                updateInterval: 0.01,
                pauseController: self.timerPauseController
            )
            self.gameTimerCreateUseCase.execute(
                request: request,
                onTimerStarted: { response in
                    self.playSound.send(response.startWhistleSound)
                    self.motionDetectorInputEvent.send(.startDeviceMotionDetection)
                    self.isWeaponChangeButtonEnabled = true
                },
                onTimerUpdated: { response in
                    self.timeCount = response.timeCount
                },
                onTimerEnded: { response in
                    self.playSound.send(response.endWhistleSound)
                    self.motionDetectorInputEvent.send(.stopDeviceMotionDetection)
                    self.isWeaponChangeButtonEnabled = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self.playSound.send(response.rankingAppearSound)
                        self.isResultViewPresented = true
                    })
                })
        })
    }
    
    private func fireWeapon() {
        guard let currentWeaponData = self.currentWeaponData else { return }

        weaponActionExecuteUseCase.fireWeapon(
            bulletsCount: currentWeaponData.state.bulletsCount,
            isReloading: currentWeaponData.state.isReloading,
            reloadType: currentWeaponData.spec.reloadType,
            onFired: { response in
                self.currentWeaponData?.state.bulletsCount = response.bulletsCount
                arControllerInputEvent.send(.renderWeaponFiring)
                playSound.send(currentWeaponData.resources.firingSound)
                
                if response.needsAutoReload {
                    // リロードを自動的に実行
                    reloadWeapon()
                }
            },
            onOutOfBullets: {
                if let outOfBulletsSound = currentWeaponData.resources.outOfBulletsSound {
                    playSound.send(outOfBulletsSound)
                }
            })
    }
    
    private func reloadWeapon() {
        guard let currentWeaponData = self.currentWeaponData else { return }
        
        // falseにリセット
        weaponReloadCanceller.isCancelled = false
        
        weaponActionExecuteUseCase.reloadWeapon(
            bulletsCount: currentWeaponData.state.bulletsCount,
            isReloading: currentWeaponData.state.isReloading,
            capacity: currentWeaponData.spec.capacity,
            reloadWaitingTime: currentWeaponData.spec.reloadWaitingTime,
            reloadCanceller: weaponReloadCanceller,
            onReloadStarted: { response in
                self.currentWeaponData?.state.isReloading = response.isReloading
                playSound.send(currentWeaponData.resources.reloadingSound)
            },
            onReloadEnded: { response in
                self.currentWeaponData?.state.bulletsCount = response.bulletsCount
                self.currentWeaponData?.state.isReloading = response.isReloading
            })
    }
}
