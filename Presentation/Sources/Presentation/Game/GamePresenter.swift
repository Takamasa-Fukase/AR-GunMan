//
//  GamePresenter.swift
//  Presentation
//
//  Created by ウルトラ深瀬 on 2026/06/19.
//

import Foundation
import Combine
import DeviceInterface
import Domain

public final class GamePresenter {
    public var timeCountText: String {
        return gameRepository.timeCountMillisec.timeCountText
    }
    public var currentWeaponType: WeaponType {
        return weaponRepository.weaponType
    }
    public var bulletsCount: String {
        return String(weaponRepository.bulletsCount)
    }

    public let isWeaponChangeButtonEnabledPublisher: AnyPublisher<Bool, Never>
    
    // showTutorialViewPublisher: とかになる予定
    public let isTutorialViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isWeaponSelectViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isResultViewPresentedPublisher: AnyPublisher<(Bool, Double), Never>
    
    private let arShootingLibHandler: ARShootingLibHandlerInterface
    private let soundPlayer: SoundPlayerInterface
    private let coreMotionHandler: CoreMotionHandlerInterface
    private let tutorialRepository: TutorialRepositoryInterface
    private let gameRepository: GameRepositoryInterface
    private let weaponRepository: WeaponRepositoryInterface
    private let weaponFireUseCase: WeaponFireUseCaseInterface
    private let weaponReloadUseCase: WeaponReloadUseCaseInterface
    private let weaponChangeUseCase: WeaponChangeUseCaseInterface
    private let gameFlowDriveUseCase: GameFlowDriveUseCaseInterface
    private let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface
    
    private let isWeaponChangeButtonEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let isTutorialViewPresentedSubject = CurrentValueSubject<Bool, Never>(false)
    private let isWeaponSelectViewPresentedSubject = CurrentValueSubject<Bool, Never>(false)
    private let isResultViewPresentedSubject = CurrentValueSubject<(Bool, Double), Never>((false, 0.0))
        
    public init(
        arShootingLibHandler: ARShootingLibHandlerInterface,
        soundPlayer: SoundPlayerInterface,
        coreMotionHandler: CoreMotionHandlerInterface,
        tutorialRepository: TutorialRepositoryInterface,
        gameRepository: GameRepositoryInterface,
        weaponRepository: WeaponRepositoryInterface,
        weaponFireUseCase: WeaponFireUseCaseInterface,
        weaponReloadUseCase: WeaponReloadUseCaseInterface,
        weaponChangeUseCase: WeaponChangeUseCaseInterface,
        gameFlowDriveUseCase: GameFlowDriveUseCaseInterface,
        weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface,
    ) {
        self.arShootingLibHandler = arShootingLibHandler
        self.soundPlayer = soundPlayer
        self.coreMotionHandler = coreMotionHandler
        self.tutorialRepository = tutorialRepository
        self.gameRepository = gameRepository
        self.weaponRepository = weaponRepository
        self.weaponFireUseCase = weaponFireUseCase
        self.weaponReloadUseCase = weaponReloadUseCase
        self.weaponChangeUseCase = weaponChangeUseCase
        self.gameFlowDriveUseCase = gameFlowDriveUseCase
        self.weaponControlMotionHandleUseCase = weaponControlMotionHandleUseCase
        
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
        
        Task {
            for await status in gameFlowDriveUseCase.statusStream {
                handleGameFlowStatus(status)
            }
        }
        
        Task {
            for await result in weaponFireUseCase.resultStream {
                handleFireResult(result)
            }
        }
        
        Task {
            for await result in weaponReloadUseCase.startResultStream {
                handleReloadStartResult(result)
            }
        }
    }
    
    // MARK: ViewからのInput
    public func onViewAppear() {
        arShootingLibHandler.showWeapon(of: .defaultType)
        arShootingLibHandler.runSession()
        gameFlowDriveUseCase.start()
    }
    
    public func onViewDisappear() {
        arShootingLibHandler.pauseSession()
    }
    
    public func tutorialEnded() {
        tutorialRepository.updateTutorialCompletedFlag(isCompleted: true)
        gameFlowDriveUseCase.resolveBlocked()
    }
    
    public func weaponChangeButtonTapped() {
        // 武器選択中はタイムカウントの更新を止める
        gameFlowDriveUseCase.pauseTimer()
        isWeaponSelectViewPresentedSubject.send(true)
    }
    
    public func weaponSelected(weaponType: WeaponType) {
        // タイムカウントの更新を再開する
        gameFlowDriveUseCase.resolveBlocked()

        weaponChangeUseCase.execute(newType: weaponType)
        arShootingLibHandler.showWeapon(of: weaponType)
    }
    
    // MARK: Privateメソッド
    private func handleGameFlowStatus(_ status: GameFlowStatus) {
        switch status {
        case .waitingForTimerStart:
            soundPlayer.play(WeaponType.defaultType.resources.appearingSound)
            
        case .timerStartedAndWaitingForTimerEnd:
            soundPlayer.play(.startWhistle)
            coreMotionHandler.startDetection()
            isWeaponChangeButtonEnabledSubject.send(true)
            
        case .timerEndedAndWaitingForFlowEnd:
            soundPlayer.play(.endWhistle)
            coreMotionHandler.stopDetection()
            isWeaponChangeButtonEnabledSubject.send(false)
            
        case .flowEnded:
            soundPlayer.play(.rankingAppear)
            isResultViewPresentedSubject.send((true, gameRepository.score))
            
        case .blocked(let reason):
            switch reason {
            case .tutorialNotCompleted:
                isTutorialViewPresentedSubject.send(true)
                
            case .timerPaused:
                break
            }
            
        case .flowNotStarted, .checkingTutorialCompletedStatus:
            break
        }
    }
    
    private func handleFireResult(_ result: WeaponFireResult) {
        switch result {
        case .success:
            arShootingLibHandler.renderWeaponFiring()
            soundPlayer.play(weaponRepository.weaponType.resources.firingSound)
            
        case .failure(let reason):
            switch reason {
            case .reloading:
                break
            case .outOfBullets:
                if let outOfBulletsSound = weaponRepository.weaponType.resources.outOfBulletsSound {
                    soundPlayer.play(outOfBulletsSound)
                }
            }
        }
    }
    
    private func handleReloadStartResult(_ result: WeaponReloadStartResult) {
        switch result {
        case .success:
            soundPlayer.play(weaponRepository.weaponType.resources.reloadingSound)
        case .failure:
            break
        }
    }
    
    private func updateReloadingMotionDetectedCount() {
        let result = gameRepository.updateReloadingMotionDetectedCount()
        switch result {
        case .notExceededLimit:
            break
        case .exceededLimit:
            soundPlayer.play(.targetAppearanceChange)
            arShootingLibHandler.changeTargetsAppearance(to: "taimeisan.jpg")
        }
    }
}

extension GamePresenter: ARShootingLibHandlerDelegate {
    public func targetHit(weaponType: WeaponType) {
        let targetHitPoint = weaponRepository.weaponType.weaponInfo.spec.targetHitPoint
        gameRepository.addScore(targetHitPoint: targetHitPoint)
        soundPlayer.play(.targetHit)
        if let bulletHitSound = weaponType.resources.bulletHitSound {
            soundPlayer.play(bulletHitSound)
        }
    }
}

extension GamePresenter: WeaponControlMotionHandleUseCaseDelegate {
    public func firingMotionDetected() {
        weaponFireUseCase.execute()
    }
    
    public func reloadingMotionDetected() {
        weaponReloadUseCase.execute()
        updateReloadingMotionDetectedCount()
    }
}
