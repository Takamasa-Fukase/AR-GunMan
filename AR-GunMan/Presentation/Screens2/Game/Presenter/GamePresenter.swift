//
//  GamePresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 20/6/24.
//

import RxSwift
import RxCocoa

struct GameControllerInput {
    let inputFromViewController: InputFromViewController
    let inputFromARContent: InputFromARContent
    let inputFromDeviceMotion: InputFromDeviceMotion

    struct InputFromViewController {
        let viewDidLoad: Observable<Void>
        let viewWillAppear: Observable<Void>
        let viewDidAppear: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let weaponChangeButtonTapped: Observable<Void>
    }
    
    struct InputFromARContent {
        let rendererUpdated: Observable<Void>
        let collisionOccurred: Observable<CollisionInfo>
    }
    
    struct InputFromDeviceMotion {
        let accelerationUpdated: Observable<Vector>
        let gyroUpdated: Observable<Vector>
    }
}

struct GameViewModel2 {
    let outputToView: OutputToView
    let outputToARContent: OutputToARContent
    let outputToDeviceMotion: OutputToDeviceMotion
    
    struct OutputToView {
        let sightImageName: Observable<String>
        let sightImageColorHexCode: Observable<String>
        let timeCountText: Observable<String>
        let bulletsCountImageName: Observable<String>
        let isWeaponChangeButtonEnabled: Observable<Bool>
    }
    
    struct OutputToARContent {
        let setupSceneView: Observable<Void>
        let renderAllTargets: Observable<Int>
        let startSceneSession: Observable<Void>
        let pauseSceneSession: Observable<Void>
        let renderSelectedWeapon: Observable<WeaponType>
        let renderWeaponFiring: Observable<WeaponType>
        let renderTargetsAppearanceChanging: Observable<Void>
        let moveWeaponToFPSPosition: Observable<WeaponType>
        let removeContactedTargetAndBullet: Observable<(targetId: UUID, bulletId: UUID)>
        let renderTargetHitParticleToContactPoint: Observable<(weaponType: WeaponType, contactPoint: Vector)>
    }
    
    struct OutputToDeviceMotion {
        let startMotionDetection: Observable<Void>
        let stopMotionDetection: Observable<Void>
    }
}

protocol GamePresenterInterface {
    func transform(input: GameControllerInput) -> GameViewModel2
}

final class GamePresenter: GamePresenterInterface {
    class State {
        let timeCountRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
        let weaponTypeRelay = BehaviorRelay<WeaponType>(value: .pistol)
        var isWeaponReloadingRelay = BehaviorRelay<Bool>(value: false)
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        let scoreRelay = BehaviorRelay<Double>(value: 0)
        let reloadingMotionDetectedCountRelay = BehaviorRelay<Int>(value: 0)
    }
    
    private let tutorialNecessityCheckUseCase: TutorialNecessityCheckUseCaseInterface
    private let tutorialEndHandlingUseCase: TutorialEndHandlingUseCaseInterface
    private let gameStartUseCase: GameStartUseCaseInterface
    private let gameTimerHandlingUseCase: GameTimerHandlingUseCaseInterface
    private let gameTimerEndHandlingUseCase: GameTimerEndHandlingUseCaseInterface
    private let fireMotionFilterUseCase: FireMotionFilterUseCaseInterface
    private let reloadMotionFilterUseCase: ReloadMotionFilterUseCaseInterface
    private let reloadMotionDetectionCountUseCase: ReloadMotionDetectionCountUseCaseInterface
    private let weaponFireUseCase: WeaponFireUseCaseInterface
    private let weaponReloadUseCase: WeaponReloadUseCaseInterface
    private let weaponAutoReloadFilterUseCase: WeaponAutoReloadFilterUseCaseInterface
    private let weaponChangeUseCase: WeaponChangeUseCaseInterface
    private let targetHitFilterUseCase: TargetHitFilterUseCaseInterface
    private let targetHitHandlingUseCase: TargetHitHandlingUseCaseInterface
    private let navigator: GameNavigatorInterface2
    private let state: State
    
    // 遷移先からの通知を受け取るレシーバー
    private let tutorialEndEventReceiver: PublishRelay<Void>
    private let weaponSelectEventReceiver: PublishRelay<WeaponType>
    
    private let disposeBag = DisposeBag()
    
    init(
        tutorialNecessityCheckUseCase: TutorialNecessityCheckUseCaseInterface,
        tutorialEndHandlingUseCase: TutorialEndHandlingUseCaseInterface,
        gameStartUseCase: GameStartUseCaseInterface,
        gameTimerHandlingUseCase: GameTimerHandlingUseCaseInterface,
        gameTimerEndHandlingUseCase: GameTimerEndHandlingUseCaseInterface,
        fireMotionFilterUseCase: FireMotionFilterUseCaseInterface,
        reloadMotionFilterUseCase: ReloadMotionFilterUseCaseInterface,
        reloadMotionDetectionCountUseCase: ReloadMotionDetectionCountUseCaseInterface,
        weaponFireUseCase: WeaponFireUseCaseInterface,
        weaponReloadUseCase: WeaponReloadUseCaseInterface,
        weaponAutoReloadFilterUseCase: WeaponAutoReloadFilterUseCaseInterface,
        weaponChangeUseCase: WeaponChangeUseCaseInterface,
        targetHitFilterUseCase: TargetHitFilterUseCaseInterface,
        targetHitHandlingUseCase: TargetHitHandlingUseCaseInterface,
        navigator: GameNavigatorInterface2,
        state: State = State(),
        tutorialEndEventReceiver: PublishRelay<Void> = PublishRelay<Void>(),
        weaponSelectEventReceiver: PublishRelay<WeaponType> = PublishRelay<WeaponType>()
    ) {
        self.tutorialNecessityCheckUseCase = tutorialNecessityCheckUseCase
        self.tutorialEndHandlingUseCase = tutorialEndHandlingUseCase
        self.gameStartUseCase = gameStartUseCase
        self.gameTimerHandlingUseCase = gameTimerHandlingUseCase
        self.gameTimerEndHandlingUseCase = gameTimerEndHandlingUseCase
        self.fireMotionFilterUseCase = fireMotionFilterUseCase
        self.reloadMotionFilterUseCase = reloadMotionFilterUseCase
        self.reloadMotionDetectionCountUseCase = reloadMotionDetectionCountUseCase
        self.weaponFireUseCase = weaponFireUseCase
        self.weaponReloadUseCase = weaponReloadUseCase
        self.weaponAutoReloadFilterUseCase = weaponAutoReloadFilterUseCase
        self.weaponChangeUseCase = weaponChangeUseCase
        self.targetHitFilterUseCase = targetHitFilterUseCase
        self.targetHitHandlingUseCase = targetHitHandlingUseCase
        self.navigator = navigator
        self.state = state
        self.tutorialEndEventReceiver = tutorialEndEventReceiver
        self.weaponSelectEventReceiver = weaponSelectEventReceiver
    }
    
    func transform(input: GameControllerInput) -> GameViewModel2 {
        let tutorialNecessityCheckUseCaseOutput = tutorialNecessityCheckUseCase
            .transform(input: .init(
                trigger: input.inputFromViewController.viewDidAppear.take(1)
            ))
        
        let tutorialEndHandlingUseCaseOutput = tutorialEndHandlingUseCase
            .transform(input: .init(
                tutorialEnded: tutorialEndEventReceiver.asObservable()
            ))
        
        let gameStartUseCaseOutput = gameStartUseCase
            .transform(input: .init(
                trigger: Observable.merge(
                    tutorialNecessityCheckUseCaseOutput.startGame,
                    tutorialEndHandlingUseCaseOutput.startGame
                )
            ))
        
        let gameTimerHandlingUseCaseOutput = gameTimerHandlingUseCase
            .transform(input: .init(
                timerStartTrigger: gameStartUseCaseOutput.startTimer
            ))
        
        let gameTimerEndHandlingUseCaseOutput = gameTimerEndHandlingUseCase
            .transform(input: .init(timerEnded: gameTimerHandlingUseCaseOutput.timerEnded))
        
        let fireMotionDetected = fireMotionFilterUseCase
            .transform(input: .init(
                accelerationUpdated: input.inputFromDeviceMotion.accelerationUpdated,
                gyroUpdated: input.inputFromDeviceMotion.gyroUpdated
            ))
            .fireMotionDetected
        
        let reloadMotionDetected = reloadMotionFilterUseCase
            .transform(input: .init(
                gyroUpdated: input.inputFromDeviceMotion.gyroUpdated
            ))
            .reloadMotionDetected
            .share()
        
        let weaponFireUseCaseOutput = weaponFireUseCase
            .transform(input: .init(
                weaponFiringTrigger: fireMotionDetected
                    .map({ [weak self] _ -> WeaponType in
                        guard let self = self else { return .pistol }
                        return self.state.weaponTypeRelay.value
                    }),
                bulletsCount: state.bulletsCountRelay.asObservable()
            ))
        
        let weaponFired = weaponFireUseCaseOutput.weaponFired
            .share()
        
        let weaponAutoReloadFilterUseCaseOutput = weaponAutoReloadFilterUseCase
            .transform(input: .init(
                weaponFired: weaponFired,
                bulletsCount: state.bulletsCountRelay.asObservable()
            ))
        
        let weaponReloadTrigger = Observable
            .merge(
                reloadMotionDetected
                    .map({ [weak self] _ -> WeaponType in
                        guard let self = self else { return .pistol }
                        return self.state.weaponTypeRelay.value
                    }),
                weaponAutoReloadFilterUseCaseOutput.reloadWeaponAutomatically
            )

        let weaponReloadUseCaseOutput = weaponReloadUseCase
            .transform(input: .init(
                weaponReloadingTrigger: weaponReloadTrigger,
                bulletsCount: state.bulletsCountRelay.asObservable(),
                isWeaponReloading: state.isWeaponReloadingRelay.asObservable()
            ))
                
        let weaponChangeUseCaseOutput = weaponChangeUseCase
            .transform(input: .init(
                weaponSelected: weaponSelectEventReceiver.asObservable()
            ))
               
        let weaponChanged = weaponChangeUseCaseOutput.weaponChanged
            .share()
        
        let targetHitFilterUseCaseOutput = targetHitFilterUseCase
            .transform(input: .init(
                collisionOccurred: input.inputFromARContent.collisionOccurred
            ))
        
        let targetHitHandlingUseCaseOutput = targetHitHandlingUseCase
            .transform(input: .init(
                targetHit: targetHitFilterUseCaseOutput.targetHit,
                currentScore: state.scoreRelay.asObservable()
            ))
        
        let reloadMotionDetectionCountUseCaseOutput = reloadMotionDetectionCountUseCase
            .transform(input: .init(
                reloadMotionDetected: reloadMotionDetected,
                currentCount: state.reloadingMotionDetectedCountRelay.asObservable())
            )
        
        
        // MARK: OutputToView
        let sightImageName = state.weaponTypeRelay
            .map({ $0.sightImageName })
        
        let sightImageColorHexCode = state.weaponTypeRelay
            .map({ $0.sightImageColorHexCode })
        
        let timeCountText = state.timeCountRelay
            .map({ TimeCountUtil.twoDigitTimeCount($0) })
        
        let bulletsCountImageName = state.bulletsCountRelay
            .map({ [weak self] in
                guard let self = self else { return "" }
                return self.state.weaponTypeRelay.value.bulletsCountImageName(at: $0)
            })
        
        let isWeaponChangeButtonEnabled = state.timeCountRelay
            .map({ $0 < GameConst.timeCount && $0 > 0 })
        
        
        // MARK: OutputToARContent
        let setupSceneView = input.inputFromViewController.viewDidLoad
        
        let renderAllTargets = input.inputFromViewController.viewDidLoad
            .map({ _ in GameConst.targetCount })
        
        let startSceneSession = input.inputFromViewController.viewWillAppear
        
        let pauseSceneSession = input.inputFromViewController.viewWillDisappear

        let renderSelectedWeapon = weaponChanged.startWith(state.weaponTypeRelay.value)

        let renderWeaponFiring = weaponFired
        
        let renderTargetsAppearanceChanging = reloadMotionDetectionCountUseCaseOutput.changeTargetsAppearance
        
        let moveWeaponToFPSPosition = input.inputFromARContent.rendererUpdated
            .map({ [weak self] _ -> WeaponType in
                guard let self = self else { return .pistol }
                return self.state.weaponTypeRelay.value
            })
        
        let removeContactedTargetAndBullet = targetHitHandlingUseCaseOutput.removeContactedTargetAndBullet
        
        let renderTargetHitParticleToContactPoint = targetHitHandlingUseCaseOutput.renderTargetHitParticleToContactPoint
        
        
        // MARK: OutputToDeviceMotion
        let startMotionDetection = gameStartUseCaseOutput.startMotionDetection
        
        let stopMotionDetection = gameTimerEndHandlingUseCaseOutput.stopMotionDetection
        
        
        disposeBag.insert {
            // MARK: State updates
            gameTimerHandlingUseCaseOutput.updateTimeCount
                .bind(to: state.timeCountRelay)
            weaponChangeUseCaseOutput.updateWeaponType
                .bind(to: state.weaponTypeRelay)
            weaponReloadUseCaseOutput.updateWeaponReloadingFlag
                .bind(to: state.isWeaponReloadingRelay)
            weaponChangeUseCaseOutput.resetWeaponReloadingFlag
                .bind(to: state.isWeaponReloadingRelay)
            weaponFireUseCaseOutput.updateBulletsCount
                .bind(to: state.bulletsCountRelay)
            weaponReloadUseCaseOutput.updateBulletsCount
                .bind(to: state.bulletsCountRelay)
            weaponChangeUseCaseOutput.refillBulletsCountForNewWeapon
                .bind(to: state.bulletsCountRelay)
            targetHitHandlingUseCaseOutput.updateScore
                .bind(to: state.scoreRelay)
            reloadMotionDetectionCountUseCaseOutput.updateCount
                .bind(to: state.reloadingMotionDetectedCountRelay)
            
            // MARK: Transitions
            tutorialNecessityCheckUseCaseOutput.showTutorial
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showTutorialView(
                        tutorialEndEventReceiver: self.tutorialEndEventReceiver
                    )
                })
            input.inputFromViewController.weaponChangeButtonTapped
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showWeaponChangeView(
                        weaponSelectEventReceiver: self.weaponSelectEventReceiver
                    )
                })
            gameTimerEndHandlingUseCaseOutput.dismissWeaponChangeView
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.dismissWeaponChangeView()
                })
            gameTimerEndHandlingUseCaseOutput.showResultView
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showResultView(score: self.state.scoreRelay.value)
                })
        }
        
        
        return GameViewModel2(
            outputToView: GameViewModel2.OutputToView(
                sightImageName: sightImageName,
                sightImageColorHexCode: sightImageColorHexCode,
                timeCountText: timeCountText,
                bulletsCountImageName: bulletsCountImageName,
                isWeaponChangeButtonEnabled: isWeaponChangeButtonEnabled
            ),
            outputToARContent: GameViewModel2.OutputToARContent(
                setupSceneView: setupSceneView,
                renderAllTargets: renderAllTargets,
                startSceneSession: startSceneSession,
                pauseSceneSession: pauseSceneSession,
                renderSelectedWeapon: renderSelectedWeapon,
                renderWeaponFiring: renderWeaponFiring,
                renderTargetsAppearanceChanging: renderTargetsAppearanceChanging,
                moveWeaponToFPSPosition: moveWeaponToFPSPosition,
                removeContactedTargetAndBullet: removeContactedTargetAndBullet,
                renderTargetHitParticleToContactPoint: renderTargetHitParticleToContactPoint
            ),
            outputToDeviceMotion: GameViewModel2.OutputToDeviceMotion(
                startMotionDetection: startMotionDetection,
                stopMotionDetection: stopMotionDetection
            )
        )
    }
}
