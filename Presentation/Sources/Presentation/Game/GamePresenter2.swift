//
//  GamePresenter2.swift
//  Presentation
//
//  Created by ウルトラ深瀬 on 2026/06/19.
//

import Foundation
import Combine
import DeviceInterface
import Domain

public final class GamePresenter2 {
    public let timeCountTextPublisher: AnyPublisher<String, Never>
    public let currentWeaponTypePublisher: AnyPublisher<WeaponType, Never>
    public let bulletsCountPublisher: AnyPublisher<String, Never>

    public let isWeaponChangeButtonEnabledPublisher: AnyPublisher<Bool, Never>
    public let isTutorialViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isWeaponSelectViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isResultViewPresentedPublisher: AnyPublisher<(Bool, Double), Never>
    
    private let arShootingLibHandler: ARShootingLibHandlerInterface
    private let soundPlayer: SoundPlayerInterface
    private let coreMotionHandler: CoreMotionHandlerInterface
    private let tutorialRepository: TutorialRepositoryInterface
    private let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface
    private let gameTimerCreateUseCase: GameTimerCreateUseCaseInterface
    private let weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    
    private let weaponChangeUseCase: WeaponChangeUseCaseInterface
    private let scoreAddUseCase: ScoreAddUseCaseInterface
    private let scoreGetUseCase: ScoreGetUseCaseInterface
    
    private let timerPauseController = GameTimerCreateRequest.PauseController()
    private let weaponReloadCanceller = WeaponReloadCanceller()
    
    private let timeCountTextSubject = PassthroughSubject<String, Never>()
    private let currentWeaponTypeSubject = PassthroughSubject<WeaponType, Never>()
    private let bulletsCountSubject = PassthroughSubject<String, Never>()

    private let isWeaponChangeButtonEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let isTutorialViewPresentedSubject = CurrentValueSubject<Bool, Never>(false)
    private let isWeaponSelectViewPresentedSubject = CurrentValueSubject<Bool, Never>(false)
    private let isResultViewPresentedSubject = CurrentValueSubject<(Bool, Double), Never>((false, 0.0))
    private var isCheckedTutorialCompletedFlag = false
    private var reloadingMotionDetecedCount: Int = 0
    
    public init(
        arShootingLibHandler: ARShootingLibHandlerInterface,
        soundPlayer: SoundPlayerInterface,
        coreMotionHandler: CoreMotionHandlerInterface,
        tutorialRepository: TutorialRepositoryInterface,
        weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface,
        gameTimerCreateUseCase: GameTimerCreateUseCaseInterface,
        weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface,
        
        weaponChangeUseCase: WeaponChangeUseCaseInterface,
        scoreAddUseCase: ScoreAddUseCaseInterface,
        scoreGetUseCase: ScoreGetUseCaseInterface
    ) {
        self.arShootingLibHandler = arShootingLibHandler
        self.soundPlayer = soundPlayer
        self.coreMotionHandler = coreMotionHandler
        self.tutorialRepository = tutorialRepository
        self.weaponControlMotionHandleUseCase = weaponControlMotionHandleUseCase
        self.gameTimerCreateUseCase = gameTimerCreateUseCase
        self.weaponActionExecuteUseCase = weaponActionExecuteUseCase
        
        self.weaponChangeUseCase = weaponChangeUseCase
        self.scoreAddUseCase = scoreAddUseCase
        self.scoreGetUseCase = scoreGetUseCase
        
        timeCountTextPublisher = timeCountTextSubject.eraseToAnyPublisher()
        currentWeaponTypePublisher = currentWeaponTypeSubject.eraseToAnyPublisher()
        bulletsCountPublisher = bulletsCountSubject.eraseToAnyPublisher()

        isWeaponChangeButtonEnabledPublisher = isWeaponChangeButtonEnabledSubject.eraseToAnyPublisher()
        isTutorialViewPresentedPublisher = isTutorialViewPresentedSubject.eraseToAnyPublisher()
        isWeaponSelectViewPresentedPublisher = isWeaponSelectViewPresentedSubject.eraseToAnyPublisher()
        isResultViewPresentedPublisher = isResultViewPresentedSubject.eraseToAnyPublisher()
        
        coreMotionHandler.accelerationUpdated = { [weak self] acceleration in
            self?.weaponControlMotionHandleUseCase.execute(acceleration: acceleration, gyro: nil)
        }
        coreMotionHandler.gyroUpdated = { [weak self] gyro in
            self?.weaponControlMotionHandleUseCase.execute(acceleration: nil ,gyro: gyro)
        }
    }
    
    // MARK: ViewからのInput
    public func onViewAppear() {
        showSelectedWeapon(WeaponType.defaultType)
        
        arShootingLibHandler.runSession()
        
        if !isCheckedTutorialCompletedFlag {
            isCheckedTutorialCompletedFlag = true
            
            let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
            if isTutorialCompleted {
                waitAndCreateTimer()
            } else {
                isTutorialViewPresentedSubject.send(true)
            }
        }
    }
    
    public func onViewDisappear() {
        arShootingLibHandler.pauseSession()
    }
    
    public func tutorialEnded() {
        tutorialRepository.updateTutorialCompletedFlag(isCompleted: true)
        waitAndCreateTimer()
    }
    
    public func weaponChangeButtonTapped() {
        // 武器選択中はタイムカウントの更新を止める
        timerPauseController.isPaused = true
        isWeaponSelectViewPresentedSubject.send(true)
    }
    
    public func weaponSelected(weaponType: WeaponType) {
        // タイムカウントの更新を再開する
        timerPauseController.isPaused = false
        // 既存のリロードをキャンセルする
        weaponReloadCanceller.isCancelled = true

        weaponChangeUseCase.execute(newWeaponType: weaponType)
        showSelectedWeapon(weaponType)
    }
    
    // MARK: Privateメソッド
    private func showSelectedWeapon(_ selectedWeaponType: WeaponType) {
        currentWeaponTypeSubject.send(selectedWeaponType)
        
        arShootingLibHandler.showWeapon(of: selectedWeaponType)
                
        if isCheckedTutorialCompletedFlag {
            soundPlayer.play(selectedWeaponType.resources.appearingSound)
        }
    }
    
    private func waitAndCreateTimer() {
        soundPlayer.play(WeaponType.defaultType.resources.appearingSound)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let request = GameTimerCreateRequest(
//                initialTimeCount: self.timeCountSubject.value,
                // FIXME: ビルド通すための暫定対応
                initialTimeCount: 30.00,
                updateInterval: 0.01,
                pauseController: self.timerPauseController
            )
            self.gameTimerCreateUseCase.execute(
                request: request,
                onTimerStarted: { [weak self] in
                    self?.soundPlayer.play(.startWhistle)
                    self?.coreMotionHandler.startDetection()
                    self?.isWeaponChangeButtonEnabledSubject.send(true)
                },
                onTimerUpdated: { [weak self] response in
//                    self?.timeCountSubject.send(response.timeCount)
                    let timeCountText = response.timeCount.timeCountText
                    self?.timeCountTextSubject.send(timeCountText)
                },
                onTimerEnded: { [weak self] in
                    self?.soundPlayer.play(.endWhistle)
                    self?.coreMotionHandler.stopDetection()
                    self?.isWeaponChangeButtonEnabledSubject.send(false)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self?.soundPlayer.play(.rankingAppear)
                        let score = self?.scoreGetUseCase.execute() ?? 0.0
                        self?.isResultViewPresentedSubject.send((true, score))
                    })
                })
        })
    }
    
    private func fireWeapon() {
//        guard let currentWeapon = currentWeaponSubject.value else { return }
//
//        weaponActionExecuteUseCase.fireWeapon(
//            bulletsCount: currentWeapon.bulletsCount,
//            isReloading: currentWeapon.isReloading,
//            reloadType: currentWeapon.weaponType.weaponInfo.spec.reloadType,
//            onFired: { [weak self] response in
//                var modifiedCurrentWeapon = currentWeapon
//                modifiedCurrentWeapon.bulletsCount = response.bulletsCount
//                self?.currentWeaponSubject.send(modifiedCurrentWeapon)
//                self?.arShootingLibHandler.renderWeaponFiring()
//                self?.soundPlayer.play(currentWeapon.weaponType.resources.firingSound)
//                
//                if response.needsAutoReload {
//                    // リロードを自動的に実行
//                    self?.reloadingMotionDetected()
//                }
//            },
//            onOutOfBullets: { [weak self] in
//                if let outOfBulletsSound = currentWeapon.weaponType.resources.outOfBulletsSound {
//                    self?.soundPlayer.play(outOfBulletsSound)
//                }
//            })
    }
    
    private func reloadWeapon() {
//        guard let currentWeapon = currentWeaponSubject.value else { return }
//
//        // falseにリセット
//        weaponReloadCanceller.isCancelled = false
//        
//        weaponActionExecuteUseCase.reloadWeapon(
//            bulletsCount: currentWeapon.bulletsCount,
//            isReloading: currentWeapon.isReloading,
//            capacity: currentWeapon.weaponType.weaponInfo.spec.capacity,
//            reloadWaitingTime: currentWeapon.weaponType.weaponInfo.spec.reloadWaitingTime,
//            reloadCanceller: weaponReloadCanceller,
//            onReloadStarted: { [weak self] response in
//                var modifiedCurrentWeapon = currentWeapon
//                modifiedCurrentWeapon.isReloading = response.isReloading
//                self?.currentWeaponSubject.send(modifiedCurrentWeapon)
//                self?.soundPlayer.play(currentWeapon.weaponType.resources.reloadingSound)
//            },
//            onReloadEnded: { [weak self] response in
//                var modifiedCurrentWeapon = currentWeapon
//                modifiedCurrentWeapon.bulletsCount = response.bulletsCount
//                modifiedCurrentWeapon.isReloading = response.isReloading
//                self?.currentWeaponSubject.send(modifiedCurrentWeapon)
//            })
    }
}

extension GamePresenter2: ARShootingLibHandlerDelegate {
    public func targetHit(weaponType: WeaponType) {
        scoreAddUseCase.execute()
        soundPlayer.play(.targetHit)
        if let bulletHitSound = weaponType.resources.bulletHitSound {
            soundPlayer.play(bulletHitSound)
        }
    }
}

extension GamePresenter2: WeaponControlMotionHandleUseCaseDelegate {
    public func firingMotionDetected() {
        fireWeapon()
    }
    
    public func reloadingMotionDetected() {
        reloadWeapon()
        
        // TODO: このカウントもGameSessionに含めてStore管理にする
        reloadingMotionDetecedCount += 1
        if reloadingMotionDetecedCount == 20 {
            soundPlayer.play(.targetAppearanceChange)
            arShootingLibHandler.changeTargetsAppearance(to: "taimeisan.jpg")
        }
    }
}
