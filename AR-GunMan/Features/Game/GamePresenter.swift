//
//  GamePresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/06/19.
//

import Foundation
import DeviceInterface
import Domain

@MainActor
public final class GamePresenter {
    public var timeCountText: String {
        return gameStore.timeCount.countMillisec.timeCountText
    }
    public var currentWeaponType: WeaponType {
        return weaponStore.weapon.currentType
    }
    public var bulletsCount: Int {
        return weaponStore.weapon.bulletsCount
    }
    public var isWeaponChangeButtonEnabled: Bool {
        switch gameStore.gameFlow.status {
        case .timerStartedAndWaitingForTimerEnd, .timerResumedAndWaitingForTimerEnd:
            return true
        default:
            return false
        }
    }
    
    public let showTutorialViewEvent: AsyncStream<Void>
    public let showWeaponSelectViewEvent: AsyncStream<Void>
    public let closeWeaponSelectViewEvent: AsyncStream<Void>
    public let showResultViewEvent: AsyncStream<Double>

    private let arGameEngineHandler: ARGameEngineHandlerInterface
    private let soundPlayer: SoundPlayerInterface
    private let motionSensorHandler: MotionSensorHandlerInterface
    private let gameStore: GameStoreInterface
    private let weaponStore: WeaponStoreInterface
    private let weaponFireUseCase: WeaponFireUseCaseInterface
    private let weaponReloadUseCase: WeaponReloadUseCaseInterface
    private let weaponChangeUseCase: WeaponChangeUseCaseInterface
    private let gameFlowDriveUseCase: GameFlowDriveUseCaseInterface
    private let scoreAddUseCase: ScoreAddUseCaseInterface
    private let reloadingMotionCountUpdateUseCase: ReloadingMotionCountUpdateUseCaseInterface
    private let weaponControlMotionDetectUseCase: WeaponControlMotionDetectUseCaseInterface
    
    private let showTutorialViewEventContinuation: AsyncStream<Void>.Continuation
    private let showWeaponSelectViewEventContinuation: AsyncStream<Void>.Continuation
    private let closeWeaponSelectViewEventContinuation: AsyncStream<Void>.Continuation
    private let showResultViewEventContinuation: AsyncStream<Double>.Continuation
    
    public init(
        arGameEngineHandler: ARGameEngineHandlerInterface,
        soundPlayer: SoundPlayerInterface,
        motionSensorHandler: MotionSensorHandlerInterface,
        gameStore: GameStoreInterface,
        weaponStore: WeaponStoreInterface,
        weaponFireUseCase: WeaponFireUseCaseInterface,
        weaponReloadUseCase: WeaponReloadUseCaseInterface,
        weaponChangeUseCase: WeaponChangeUseCaseInterface,
        gameFlowDriveUseCase: GameFlowDriveUseCaseInterface,
        scoreAddUseCase: ScoreAddUseCaseInterface,
        reloadingMotionCountUpdateUseCase: ReloadingMotionCountUpdateUseCaseInterface,
        weaponControlMotionDetectUseCase: WeaponControlMotionDetectUseCaseInterface
    ) {
        self.arGameEngineHandler = arGameEngineHandler
        self.soundPlayer = soundPlayer
        self.motionSensorHandler = motionSensorHandler
        self.gameStore = gameStore
        self.weaponStore = weaponStore
        self.weaponFireUseCase = weaponFireUseCase
        self.weaponReloadUseCase = weaponReloadUseCase
        self.weaponChangeUseCase = weaponChangeUseCase
        self.gameFlowDriveUseCase = gameFlowDriveUseCase
        self.scoreAddUseCase = scoreAddUseCase
        self.reloadingMotionCountUpdateUseCase = reloadingMotionCountUpdateUseCase
        self.weaponControlMotionDetectUseCase = weaponControlMotionDetectUseCase
        
        (showTutorialViewEvent, showTutorialViewEventContinuation) = AsyncStream.makeStream()
        (showWeaponSelectViewEvent, showWeaponSelectViewEventContinuation) = AsyncStream.makeStream()
        (closeWeaponSelectViewEvent, closeWeaponSelectViewEventContinuation) = AsyncStream.makeStream()
        (showResultViewEvent, showResultViewEventContinuation) = AsyncStream.makeStream()
        
        // TODO: weak selfが危険なのでクロージャーじゃ無い書き方に差し替えを検討したい
        arGameEngineHandler.targetHit = { [weak self] weaponType in
            scoreAddUseCase.execute(targetHitPoint: weaponType.targetHitPoint)
            soundPlayer.play(.targetHit)
            if let bulletHitSound = weaponType.resources.bulletHitSound {
                soundPlayer.play(bulletHitSound)
            }
        }
        
        // TODO: weak selfが危険なのでクロージャーじゃ無い書き方に差し替えを検討したい
        motionSensorHandler.motionUpdated = { [weak self] motion in
            // 物理モーションを武器の操作モーションに変換
            let weaponControlMotion = weaponControlMotionDetectUseCase.execute(motion: motion)
            
            // 武器の操作モーションでは無い場合はreturn
            guard let weaponControlMotion = weaponControlMotion else { return }
            
            // 武器の操作モーション種別をハンドリング
            switch weaponControlMotion {
            case .fire:
                // 武器の発射
                weaponFireUseCase.execute()
                
            case .reload:
                // 武器のリロード
                weaponReloadUseCase.execute()
                
                // リロードモーションの検知回数をカウント
                let reloadingMotionCountUpdateResult = reloadingMotionCountUpdateUseCase.execute()
                
                // リロードモーションの検知回数に応じた結果のハンドリング
                switch reloadingMotionCountUpdateResult {
                case .notExceededLimit:
                    break
                case .exceededLimit:
                    soundPlayer.play(.targetAppearanceChange)
                    arGameEngineHandler.changeTargetsAppearance(to: "taimeisan.jpg")
                }
            }
        }
        
        Task {
            for await fireResult in weaponFireUseCase.fireResultEvent {
                // 発射結果のハンドリング
                switch fireResult {
                case .success:
                    arGameEngineHandler.renderWeaponFiring()
                    soundPlayer.play(weaponStore.weapon.currentType.resources.firingSound)
                    
                case .failure(let reason):
                    switch reason {
                    case .reloading:
                        break
                    case .outOfBullets:
                        if let outOfBulletsSound = weaponStore.weapon.currentType.resources.outOfBulletsSound {
                            soundPlayer.play(outOfBulletsSound)
                        }
                    }
                }
            }
        }
        
        Task {
            for await reloadStartResult in weaponReloadUseCase.reloadStartResultEvent {
                // リロード開始結果のハンドリング
                switch reloadStartResult {
                case .success:
                    soundPlayer.play(weaponStore.weapon.currentType.resources.reloadingSound)
                    
                case .failure:
                    break
                }
            }
        }
        
        Task {
            for await status in gameFlowDriveUseCase.statusStream {
                switch status {
                case .waitingForTimerStart:
                    soundPlayer.play(WeaponType.defaultType.resources.appearingSound)
                    
                case .timerStartedAndWaitingForTimerEnd:
                    soundPlayer.play(.startWhistle)
                    motionSensorHandler.startDetection()
                    
                case .timerEndedAndWaitingForFlowEnd:
                    soundPlayer.play(.endWhistle)
                    motionSensorHandler.stopDetection()
                    closeWeaponSelectViewEventContinuation.yield()
                    
                case .flowEnded:
                    soundPlayer.play(.rankingAppear)
                    showResultViewEventContinuation.yield(gameStore.score.value)
                    
                case .blocked(let reason):
                    switch reason {
                    case .tutorialNotCompleted:
                        showTutorialViewEventContinuation.yield()
                        
                    case .timerPaused:
                        break
                    }
                    
                case .flowNotStarted, .timerResumedAndWaitingForTimerEnd, .checkingTutorialCompletedStatus:
                    break
                }
            }
        }
    }
    
    // MARK: ViewからのInput
    public func onViewAppear() {
        gameStore.reset()
        weaponStore.reset()
        
        // TODO: 検証 - 呼び出し順逆の方がいいか？
        arGameEngineHandler.showWeapon(of: .defaultType)
        arGameEngineHandler.run()
        gameFlowDriveUseCase.start()
    }
    
    public func onViewDisappear() {
        arGameEngineHandler.pause()
    }
    
    public func tutorialEnded() {
        gameFlowDriveUseCase.resolveBlocked()
    }
    
    public func weaponChangeButtonTapped() {
        showWeaponSelectViewEventContinuation.yield()

        // 武器選択中はタイムカウントの更新を止める
        gameFlowDriveUseCase.pauseTimer()
    }
    
    public func weaponSelected(weaponType: WeaponType) {
        weaponChangeUseCase.execute(newType: weaponType)
        arGameEngineHandler.showWeapon(of: weaponType)
        soundPlayer.play(weaponType.resources.appearingSound)
        
        // タイムカウントの更新を再開する
        gameFlowDriveUseCase.resolveBlocked()
    }
}
