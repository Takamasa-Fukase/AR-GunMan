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

@MainActor
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
    public var isWeaponChangeButtonEnabled: Bool {
        switch gameRepository.gameFlowStatus {
        case .timerStartedAndWaitingForTimerEnd, .timerResumedAndWaitingForTimerEnd:
            return true
        default:
            return false
        }
    }
    
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
    private let weaponControlMotionDetectUseCase: WeaponControlMotionDetectUseCaseInterface
    
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
        weaponControlMotionDetectUseCase: WeaponControlMotionDetectUseCaseInterface
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
        self.weaponControlMotionDetectUseCase = weaponControlMotionDetectUseCase
        
        isTutorialViewPresentedPublisher = isTutorialViewPresentedSubject.eraseToAnyPublisher()
        isWeaponSelectViewPresentedPublisher = isWeaponSelectViewPresentedSubject.eraseToAnyPublisher()
        isResultViewPresentedPublisher = isResultViewPresentedSubject.eraseToAnyPublisher()
        
        Task {
            for await weaponType in arShootingLibHandler.targetHitStream {
                handleTargetHit(weaponType)
            }
        }
        
        coreMotionHandler.accelerationUpdated = { [weak self] acceleration in
            self?.weaponControlMotionDetectUseCase.execute(acceleration: acceleration, gyro: nil)
        }
        
        coreMotionHandler.gyroUpdated = { [weak self] gyro in
            self?.weaponControlMotionDetectUseCase.execute(acceleration: nil ,gyro: gyro)
        }
        
        Task {
            for await motion in weaponControlMotionDetectUseCase.detectedMotionStream {
                handleDetectedMotion(motion)
            }
        }
        
        Task {
            for await status in gameFlowDriveUseCase.statusStream {
                handleGameFlowStatus(status)
            }
        }
        
        Task {
            for await result in weaponFireUseCase.resultStream {
                handleWeaponFireResult(result)
            }
        }
        
        Task {
            for await result in weaponReloadUseCase.startResultStream {
                handleWeaponReloadStartResult(result)
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
        isWeaponSelectViewPresentedSubject.send(true)

        // 武器選択中はタイムカウントの更新を止める
        gameFlowDriveUseCase.pauseTimer()
    }
    
    public func weaponSelected(weaponType: WeaponType) {
        weaponChangeUseCase.execute(newType: weaponType)
        arShootingLibHandler.showWeapon(of: weaponType)
        soundPlayer.play(weaponType.resources.appearingSound)
        
        // タイムカウントの更新を再開する
        gameFlowDriveUseCase.resolveBlocked()
    }
    
    // MARK: Privateメソッド
    private func handleTargetHit(_ weaponType: WeaponType) {
        gameRepository.addScore(targetHitPoint: weaponType.weaponInfo.spec.targetHitPoint)
        soundPlayer.play(.targetHit)
        if let bulletHitSound = weaponType.resources.bulletHitSound {
            soundPlayer.play(bulletHitSound)
        }
    }
    
    private func handleDetectedMotion(_ motion: WeaponControlMotion) {
        switch motion {
        case .fire:
            weaponFireUseCase.execute()
            
        case .reload:
            weaponReloadUseCase.execute()
            updateReloadingMotionDetectedCount()
        }
    }
    
    private func handleGameFlowStatus(_ status: GameFlowStatus) {
        switch status {
        case .waitingForTimerStart:
            soundPlayer.play(WeaponType.defaultType.resources.appearingSound)
            
        case .timerStartedAndWaitingForTimerEnd:
            soundPlayer.play(.startWhistle)
            coreMotionHandler.startDetection()
            
        case .timerEndedAndWaitingForFlowEnd:
            soundPlayer.play(.endWhistle)
            coreMotionHandler.stopDetection()
            
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
            
        case .flowNotStarted, .timerResumedAndWaitingForTimerEnd, .checkingTutorialCompletedStatus:
            break
        }
    }
    
    private func handleWeaponFireResult(_ result: WeaponFireResult) {
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
    
    private func handleWeaponReloadStartResult(_ result: WeaponReloadStartResult) {
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
