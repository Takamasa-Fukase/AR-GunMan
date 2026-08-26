//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/06/19.
//

import Foundation
import Observation
import Device
import Domain

@Observable
@MainActor
final class GameViewModel {
    var timeCountText: String {
        return gameStore.timeCount.countMillisec.timeCountText
    }
    var currentWeaponType: WeaponType {
        return weaponStore.weapon.currentType
    }
    var sightImageName: String {
        return currentWeaponType.uiResources.sightImageName
    }
    var bulletsCountImageName: String {
        return currentWeaponType.uiResources.bulletsCountImageName(weaponStore.weapon.bulletsCount)
    }
    var isWeaponChangeButtonEnabled: Bool {
        switch gameStore.gameFlow.status {
        case .timerStartedAndWaitingForTimerEnd, .timerResumedAndWaitingForTimerEnd:
            return true
        default:
            return false
        }
    }
    var isTutorialViewPresented = false
    var isWeaponSelectViewPresented = false
    var isResultViewPresented: (isPresented: Bool, score: Double) = (false, 0.0)
    
    private let arShootingEngineHandler: ARShootingEngineHandlerInterface
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
    
    init(
        arShootingEngineHandler: ARShootingEngineHandlerInterface,
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
        self.arShootingEngineHandler = arShootingEngineHandler
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
        
        arShootingEngineHandler.targetHit = { weaponType in
            scoreAddUseCase.execute(targetHitPoint: weaponType.targetHitPoint)
            soundPlayer.play(.targetHit)
            if let bulletHitSound = weaponType.soundResources.bulletHitSound {
                soundPlayer.play(bulletHitSound)
            }
        }
        
        motionSensorHandler.motionUpdated = { motion in
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
                    arShootingEngineHandler.changeTargetsAppearance()
                }
            }
        }
        
        Task {
            for await fireResult in weaponFireUseCase.fireResultEvent {
                // 発射結果のハンドリング
                switch fireResult {
                case .success:
                    arShootingEngineHandler.renderWeaponFiring()
                    soundPlayer.play(weaponStore.weapon.currentType.soundResources.firingSound)
                    
                case .failure(let reason):
                    switch reason {
                    case .reloading:
                        break
                    case .outOfBullets:
                        if let outOfBulletsSound = weaponStore.weapon.currentType.soundResources.outOfBulletsSound {
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
                    soundPlayer.play(weaponStore.weapon.currentType.soundResources.reloadingSound)
                    
                case .failure:
                    break
                }
            }
        }
        
        Task {
            for await status in gameFlowDriveUseCase.statusStream {
                switch status {
                case .waitingForTimerStart:
                    soundPlayer.play(WeaponType.defaultType.soundResources.appearingSound)
                    
                case .timerStartedAndWaitingForTimerEnd:
                    soundPlayer.play(.startWhistle)
                    motionSensorHandler.startDetection()
                    
                case .timerEndedAndWaitingForFlowEnd:
                    soundPlayer.play(.endWhistle)
                    motionSensorHandler.stopDetection()
                    isWeaponSelectViewPresented = false
                    
                case .flowEnded:
                    soundPlayer.play(.rankingAppear)
                    isResultViewPresented = (true, gameStore.score.value)
                    
                case .blocked(let reason):
                    switch reason {
                    case .tutorialNotCompleted:
                        isTutorialViewPresented = true
                        
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
    func onViewAppear() {
        gameStore.reset()
        weaponStore.reset()
        
        arShootingEngineHandler.run()
        arShootingEngineHandler.showWeapon(of: .defaultType)
        gameFlowDriveUseCase.start()
    }
    
    func onViewDisappear() {
        arShootingEngineHandler.pause()
    }
    
    func tutorialEnded() {
        gameFlowDriveUseCase.resolveBlocked()
    }
    
    func weaponChangeButtonTapped() {
        isWeaponSelectViewPresented = true

        // 武器選択中はタイムカウントの更新を止める
        gameFlowDriveUseCase.pauseTimer()
    }
    
    func weaponSelected(weaponType: WeaponType) {
        weaponChangeUseCase.execute(newType: weaponType)
        arShootingEngineHandler.showWeapon(of: weaponType)
        soundPlayer.play(weaponType.soundResources.appearingSound)
        
        // タイムカウントの更新を再開する
        gameFlowDriveUseCase.resolveBlocked()
    }
}
