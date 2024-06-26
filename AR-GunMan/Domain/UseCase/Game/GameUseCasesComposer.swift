//
//  GameUseCasesComposer.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 24/6/24.
//

import RxSwift
import RxCocoa

struct GameUseCasesComposerInput {
    // triggers
    let tutorialNecessityCheckTrigger: Observable<Void>
    let tutorialEnded: Observable<Void>
    let accelerationUpdated: Observable<Vector>
    let gyroUpdated: Observable<Vector>
    let weaponSelected: Observable<WeaponType>
    let collisionOccurred: Observable<CollisionInfo>
    
    // states
    let weaponType: Observable<WeaponType>
    let bulletsCount: Observable<Int>
    let isWeaponReloading: Observable<Bool>
    let score: Observable<Double>
    let reloadingMotionDetectedCount: Observable<Int>
}

struct GameUseCasesComposerOutput {
    let weaponChanged: Observable<WeaponType>
    let weaponFired: Observable<WeaponType>
    let changeTargetsAppearance: Observable<Void>
    let removeContactedTargetAndBullet: Observable<(targetId: UUID, bulletId: UUID)>
    let renderTargetHitParticleToContactPoint: Observable<(weaponType: WeaponType, contactPoint: Vector)>
    let startMotionDetection: Observable<Void>
    let stopMotionDetection: Observable<Void>
    let updateTimeCount: Observable<Double>
    let updateWeaponType: Observable<WeaponType>
    let updateWeaponReloadingFlag: Observable<Bool>
    let updateBulletsCount: Observable<Int>
    let updateScore: Observable<Double>
    let updateReloadMotionDetectionCount: Observable<Int>
    let showTutorial: Observable<Void>
    let dismissWeaponChangeView: Observable<Void>
    let showResultView: Observable<Void>
}

protocol GameUseCasesComposerInterface {
    func transform(input: GameUseCasesComposerInput) -> GameUseCasesComposerOutput
}

final class GameUseCasesComposer: GameUseCasesComposerInterface {
    struct UseCases {
        let tutorialNecessityCheckUseCase: TutorialNecessityCheckUseCaseInterface
        let tutorialEndHandlingUseCase: TutorialEndHandlingUseCaseInterface
        let gameStartUseCase: GameStartUseCaseInterface
        let gameTimerHandlingUseCase: GameTimerHandlingUseCaseInterface
        let gameTimerEndHandlingUseCase: GameTimerEndHandlingUseCaseInterface
        let fireMotionFilterUseCase: FireMotionFilterUseCaseInterface
        let reloadMotionFilterUseCase: ReloadMotionFilterUseCaseInterface
        let reloadMotionDetectionCountUseCase: ReloadMotionDetectionCountUseCaseInterface
        let weaponFireUseCase: WeaponFireUseCaseInterface
        let weaponReloadUseCase: WeaponReloadUseCaseInterface
        let weaponAutoReloadFilterUseCase: WeaponAutoReloadFilterUseCaseInterface
        let weaponChangeUseCase: WeaponChangeUseCaseInterface
        let targetHitFilterUseCase: TargetHitFilterUseCaseInterface
        let targetHitHandlingUseCase: TargetHitHandlingUseCaseInterface
    }
    
    private let useCases: UseCases
    
    init(useCases: UseCases) {
        self.useCases = useCases
    }
    
    func transform(input: GameUseCasesComposerInput) -> GameUseCasesComposerOutput {
        let tutorialNecessityCheckUseCaseOutput = useCases.tutorialNecessityCheckUseCase
            .transform(input: .init(
                trigger: input.tutorialNecessityCheckTrigger
            ))
        
        let tutorialEndHandlingUseCaseOutput = useCases.tutorialEndHandlingUseCase
            .transform(input: .init(
                tutorialEnded: input.tutorialEnded
            ))
        
        let gameStartUseCaseOutput = useCases.gameStartUseCase
            .transform(input: .init(
                trigger: Observable.merge(
                    tutorialNecessityCheckUseCaseOutput.startGame,
                    tutorialEndHandlingUseCaseOutput.startGame
                )
            ))
        
        let gameTimerHandlingUseCaseOutput = useCases.gameTimerHandlingUseCase
            .transform(input: .init(
                timerStartTrigger: gameStartUseCaseOutput.startTimer
            ))
        
        let gameTimerEndHandlingUseCaseOutput = useCases.gameTimerEndHandlingUseCase
            .transform(input: .init(
                timerEnded: gameTimerHandlingUseCaseOutput.timerEnded
            ))
        
        let fireMotionDetected = useCases.fireMotionFilterUseCase
            .transform(input: .init(
                accelerationUpdated: input.accelerationUpdated,
                gyroUpdated: input.gyroUpdated
            ))
            .fireMotionDetected
        
        let reloadMotionDetected = useCases.reloadMotionFilterUseCase
            .transform(input: .init(
                gyroUpdated: input.gyroUpdated
            ))
            .reloadMotionDetected
            .share()
        
        let weaponFireUseCaseOutput = useCases.weaponFireUseCase
            .transform(input: .init(
                weaponFiringTrigger: fireMotionDetected.withLatestFrom(
                    Observable.combineLatest(
                        input.weaponType,
                        input.bulletsCount
                    )
                ) { ($1.0, $1.1) }
            ))
        
        let weaponFired = weaponFireUseCaseOutput.weaponFired
            .share()
        
        let weaponAutoReloadFilterUseCaseOutput = useCases.weaponAutoReloadFilterUseCase
            .transform(input: .init(
                weaponFired: weaponFired,
                bulletsCount: input.bulletsCount
            ))
        
        let weaponReloadTrigger = Observable
            .merge(
                reloadMotionDetected.withLatestFrom(input.weaponType),
                weaponAutoReloadFilterUseCaseOutput.reloadWeaponAutomatically
            )

        let weaponReloadUseCaseOutput = useCases.weaponReloadUseCase
            .transform(input: .init(
                weaponReloadingTrigger: weaponReloadTrigger,
                bulletsCount: input.bulletsCount,
                isWeaponReloading: input.isWeaponReloading
            ))
                
        let weaponChangeUseCaseOutput = useCases.weaponChangeUseCase
            .transform(input: .init(
                weaponSelected: input.weaponSelected
            ))
               
        let weaponChanged = weaponChangeUseCaseOutput.weaponChanged
            .share()
        
        let targetHitFilterUseCaseOutput = useCases.targetHitFilterUseCase
            .transform(input: .init(
                collisionOccurred: input.collisionOccurred
            ))
        
        let targetHitHandlingUseCaseOutput = useCases.targetHitHandlingUseCase
            .transform(input: .init(
                targetHit: targetHitFilterUseCaseOutput.targetHit,
                currentScore: input.score
            ))
        
        let reloadMotionDetectionCountUseCaseOutput = useCases.reloadMotionDetectionCountUseCase
            .transform(input: .init(
                reloadMotionDetected: reloadMotionDetected,
                currentCount: input.reloadingMotionDetectedCount
            ))
        
        let updateBulletsCount = Observable
            .merge(
                weaponFireUseCaseOutput.updateBulletsCount,
                weaponReloadUseCaseOutput.updateBulletsCount,
                weaponChangeUseCaseOutput.refillBulletsCountForNewWeapon
            )
        
        let updateWeaponReloadingFlag = Observable
            .merge(
                weaponReloadUseCaseOutput.updateWeaponReloadingFlag,
                weaponChangeUseCaseOutput.resetWeaponReloadingFlag
            )
        
        return GameUseCasesComposerOutput(
            weaponChanged: weaponChanged,
            weaponFired: weaponFired,
            changeTargetsAppearance: reloadMotionDetectionCountUseCaseOutput.changeTargetsAppearance,
            removeContactedTargetAndBullet: targetHitHandlingUseCaseOutput.removeContactedTargetAndBullet,
            renderTargetHitParticleToContactPoint: targetHitHandlingUseCaseOutput.renderTargetHitParticleToContactPoint,
            startMotionDetection: gameStartUseCaseOutput.startMotionDetection,
            stopMotionDetection: gameTimerEndHandlingUseCaseOutput.stopMotionDetection,
            updateTimeCount: gameTimerHandlingUseCaseOutput.updateTimeCount,
            updateWeaponType: weaponChangeUseCaseOutput.updateWeaponType,
            updateWeaponReloadingFlag: updateWeaponReloadingFlag,
            updateBulletsCount: updateBulletsCount,
            updateScore: targetHitHandlingUseCaseOutput.updateScore,
            updateReloadMotionDetectionCount: reloadMotionDetectionCountUseCaseOutput.updateCount,
            showTutorial: tutorialNecessityCheckUseCaseOutput.showTutorial,
            dismissWeaponChangeView: gameTimerEndHandlingUseCaseOutput.dismissWeaponChangeView,
            showResultView: gameTimerEndHandlingUseCaseOutput.showResultView
        )
    }
}
