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
    public let timeCountTextPublisher: AnyPublisher<String, Never>
    public var currentWeaponType: WeaponType {
        return weaponRepository.weapon.currentType
    }
    public var bulletsCount: String {
        return String(weaponRepository.weapon.bulletsCount)
    }

    public let isWeaponChangeButtonEnabledPublisher: AnyPublisher<Bool, Never>
    
    // showTutorialViewPublisher: とかになる予定
    public let isTutorialViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isWeaponSelectViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isResultViewPresentedPublisher: AnyPublisher<(Bool, Double), Never>
    
    private let arShootingLibHandler: ARShootingLibHandlerInterface
    private let soundPlayer: SoundPlayerInterface
    private let coreMotionHandler: CoreMotionHandlerInterface
    private let tutorialRepository: TutorialRepositoryInterface // 無くなる予定
    private let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface
    private let gameTimerCreateUseCase: GameTimerCreateUseCaseInterface // 無くなる予定
    
    private let gameSessionRepository: GameSessionRepositoryInterface
    private let weaponRepository: WeaponRepositoryInterface
    private let weaponFireUseCase: WeaponFireUseCaseInterface
    private let weaponReloadUseCase: WeaponReloadUseCaseInterface
    private let weaponChangeUseCase: WeaponChangeUseCaseInterface
    private let scoreAddUseCase: ScoreAddUseCaseInterface
    
    private let timerPauseController = GameTimerCreateRequest.PauseController() // 無くなる予定
    private var weaponReloadTask: Task<Void, Never>?
    
    private let timeCountTextSubject = PassthroughSubject<String, Never>()
    private let isWeaponChangeButtonEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let isTutorialViewPresentedSubject = CurrentValueSubject<Bool, Never>(false)
    private let isWeaponSelectViewPresentedSubject = CurrentValueSubject<Bool, Never>(false)
    private let isResultViewPresentedSubject = CurrentValueSubject<(Bool, Double), Never>((false, 0.0))
    
    private var isCheckedTutorialCompletedFlag = false // 無くなる予定
    private var reloadingMotionDetecedCount: Int = 0 // 無くなる予定
    
    public init(
        arShootingLibHandler: ARShootingLibHandlerInterface,
        soundPlayer: SoundPlayerInterface,
        coreMotionHandler: CoreMotionHandlerInterface,
        tutorialRepository: TutorialRepositoryInterface,
        weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface,
        gameTimerCreateUseCase: GameTimerCreateUseCaseInterface,
        
        gameSessionRepository: GameSessionRepositoryInterface,
        weaponRepository: WeaponRepositoryInterface,
        weaponFireUseCase: WeaponFireUseCaseInterface,
        weaponReloadUseCase: WeaponReloadUseCaseInterface,
        weaponChangeUseCase: WeaponChangeUseCaseInterface,
        scoreAddUseCase: ScoreAddUseCaseInterface,
    ) {
        self.arShootingLibHandler = arShootingLibHandler
        self.soundPlayer = soundPlayer
        self.coreMotionHandler = coreMotionHandler
        self.tutorialRepository = tutorialRepository
        self.weaponControlMotionHandleUseCase = weaponControlMotionHandleUseCase
        self.gameTimerCreateUseCase = gameTimerCreateUseCase
        
        self.gameSessionRepository = gameSessionRepository
        self.weaponRepository = weaponRepository
        self.weaponFireUseCase = weaponFireUseCase
        self.weaponReloadUseCase = weaponReloadUseCase
        self.weaponChangeUseCase = weaponChangeUseCase
        self.scoreAddUseCase = scoreAddUseCase
        
        timeCountTextPublisher = timeCountTextSubject.eraseToAnyPublisher()
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
        weaponReloadTask?.cancel()
        weaponReloadTask = nil

        weaponChangeUseCase.execute(newType: weaponType)
        showSelectedWeapon(weaponType)
    }
    
    // MARK: Privateメソッド
    private func showSelectedWeapon(_ selectedWeaponType: WeaponType) {
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
                        let score = self?.gameSessionRepository.session.score.value ?? 0.0
                        self?.isResultViewPresentedSubject.send((true, score))
                    })
                })
        })
    }
    
    private func fireWeapon() {
        let result = weaponFireUseCase.execute()
        switch result {
        case .success(let needsAutoReload):
            arShootingLibHandler.renderWeaponFiring()
            soundPlayer.play(weaponRepository.weapon.currentType.resources.firingSound)
            
            if needsAutoReload {
                // リロードを自動的に実行
                reloadingMotionDetected()
            }
            
        case .failure(let reason):
            switch reason {
            case .reloading:
                break
            case .outOfBullets:
                if let outOfBulletsSound = weaponRepository.weapon.currentType.resources.outOfBulletsSound {
                    soundPlayer.play(outOfBulletsSound)
                }
            }
        }
    }
    
    private func reloadWeapon() {
        let response = weaponReloadUseCase.execute()
        weaponReloadTask = response.reloadTask
        switch response.startResult {
        case .success:
            soundPlayer.play(weaponRepository.weapon.currentType.resources.reloadingSound)
        case .failure:
            break
        }
    }
}

extension GamePresenter: ARShootingLibHandlerDelegate {
    public func targetHit(weaponType: WeaponType) {
        scoreAddUseCase.execute()
        soundPlayer.play(.targetHit)
        if let bulletHitSound = weaponType.resources.bulletHitSound {
            soundPlayer.play(bulletHitSound)
        }
    }
}

extension GamePresenter: WeaponControlMotionHandleUseCaseDelegate {
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
