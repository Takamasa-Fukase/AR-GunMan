//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/5/24.
//

import RxSwift
import RxCocoa

final class GameViewModel: ViewModelType {
    struct Input {
        let inputFromView: InputFromView
        let inputFromARContent: InputFromARContent
        let inputFromDeviceMotion: InputFromDeviceMotion

        struct InputFromView {
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
            let accelerationUpdated: Observable<(x: Double, y: Double, z: Double)>
            let gyroUpdated: Observable<(x: Double, y: Double, z: Double)>
        }
    }
    
    struct Output {
        let viewModelAction: ViewModelAction
        let outputToView: OutputToView
        let outputToARContent: OutputToARContent
        let outputToDeviceMotion: OutputToDeviceMotion
        
        struct ViewModelAction {
            // sound playings
            let pistolSetSoundPlayed: Observable<SoundType>
            let startWhistleSoundPlayed: Observable<SoundType>
            let firingSoundPlayed: Observable<SoundType>
            let noBulletsSoundPlayed: Observable<SoundType>
            let reloadingSoundPlayed: Observable<SoundType>
            let targetHitSoundPlayed: Observable<SoundType>
            let targetsAppearanceChangingSoundPlayed: Observable<SoundType>
            let weaponChangingSoundPlayed: Observable<SoundType>
            let endWhistleSoundPlayed: Observable<SoundType>
            let rankingAppearSoundPlayed: Observable<SoundType>
            
            // state changes
            let bulletsCountDecremented: Observable<Int>
            let bulletsCountRefilled: Observable<Int>
            let bulletsCountRefilledForNewWeapon: Observable<Int>
            let weaponReloadingFlagChanged: Observable<Bool>
            let weaponReloadingFlagChangedForNewWeapon: Observable<Bool>
            let weaponTypeChanged: Observable<WeaponType>
            let scoreUpdated: Observable<Double>
            let reloadingMotionDetectedCountUpdated: Observable<Int>
            
            // transitions
            let tutorialViewShowed: Observable<Void>
            let weaponChangeViewShowed: Observable<Void>
            let weaponChangeViewDismissedOnTimerDisposal: Observable<Void>
            let resultViewShowed: Observable<Void>
            
            // others
            let weaponFireProcessCompleted: Observable<WeaponType>
            let weaponReloadProcessCompleted: Observable<WeaponType>
            let weaponChangeProcessCompleted: Observable<WeaponType>
            let timerDisposed: Observable<Void>
        }
        
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
    
    class State {
        let timeCountRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
        let weaponTypeRelay = BehaviorRelay<WeaponType>(value: .pistol)
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        var isWeaponReloadingRelay = BehaviorRelay<Bool>(value: false)
        let scoreRelay = BehaviorRelay<Double>(value: 0)
        let reloadingMotionDetectedCountRelay = BehaviorRelay<Int>(value: 0)
    }

    private let useCase: GameUseCaseInterface
    private let navigator: GameNavigatorInterface
    private let tutorialEndObserver: PublishRelay<Void>
    private let weaponSelectObserver: PublishRelay<WeaponType>
    private let tutorialSeenStatusHandler: TutorialSeenStatusHandler
    private let gameStartHandler: GameStartHandler
    private let gameTimerHandler: GameTimerHandler
    private let gameTimerDisposalHandler: GameTimerDisposalHandler
    private let firingMoitonFilter: FiringMotionFilter
    private let reloadingMotionFilter: ReloadingMotionFilter
    private let weaponFireHandler: WeaponFireHandler
    private let weaponAutoReloadFilter: WeaponAutoReloadFilter
    private let weaponReloadHandler: WeaponReloadHandler
    private let weaponSelectHandler: WeaponSelectHandler
    private let targetHitFilter: TargetHitFilter
    private let targetHitHandler: TargetHitHandler
    private let reloadingMotionDetectionCounter: ReloadingMotionDetectionCounter
    private let state: State
    private let soundPlayer: SoundPlayerInterface
    
    init(
        useCase: GameUseCaseInterface,
        navigator: GameNavigatorInterface,
        tutorialEndObserver: PublishRelay<Void> = PublishRelay<Void>(),
        weaponSelectObserver: PublishRelay<WeaponType> = PublishRelay<WeaponType>(),
        tutorialSeenStatusHandler: TutorialSeenStatusHandler,
        gameStartHandler: GameStartHandler,
        gameTimerHandler: GameTimerHandler,
        gameTimerDisposalHandler: GameTimerDisposalHandler,
        firingMoitonFilter: FiringMotionFilter,
        reloadingMotionFilter: ReloadingMotionFilter,
        weaponFireHandler: WeaponFireHandler,
        weaponAutoReloadFilter: WeaponAutoReloadFilter,
        weaponReloadHandler: WeaponReloadHandler,
        weaponSelectHandler: WeaponSelectHandler,
        targetHitFilter: TargetHitFilter,
        targetHitHandler: TargetHitHandler,
        reloadingMotionDetectionCounter: ReloadingMotionDetectionCounter,
        state: State = State(),
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared
    ) {
        self.useCase = useCase
        self.navigator = navigator
        self.tutorialEndObserver = tutorialEndObserver
        self.weaponSelectObserver = weaponSelectObserver
        self.tutorialSeenStatusHandler = tutorialSeenStatusHandler
        self.gameStartHandler = gameStartHandler
        self.gameTimerHandler = gameTimerHandler
        self.gameTimerDisposalHandler = gameTimerDisposalHandler
        self.firingMoitonFilter = firingMoitonFilter
        self.reloadingMotionFilter = reloadingMotionFilter
        self.weaponFireHandler = weaponFireHandler
        self.weaponAutoReloadFilter = weaponAutoReloadFilter
        self.weaponReloadHandler = weaponReloadHandler
        self.weaponSelectHandler = weaponSelectHandler
        self.targetHitFilter = targetHitFilter
        self.targetHitHandler = targetHitHandler
        self.reloadingMotionDetectionCounter = reloadingMotionDetectionCounter
        self.state = state
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: Input) -> Output {
        // MARK: ViewModelAction
        let tutorialSeenStatusHandlerOutput = tutorialSeenStatusHandler
            .transform(input: .init(
                checkTutorialSeenStatus: input.inputFromView.viewDidAppear.take(1))
            )
        
        let tutorialViewShowed = tutorialSeenStatusHandlerOutput.showTutorial
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showTutorialView(
                    tutorialEndObserver: self.tutorialEndObserver
                )
            })
        
        let gameStartAfterTutorialTrigger = tutorialEndObserver
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.useCase.setTutorialAlreadySeen()
            })
        
        let gameStartHandlerOutput = gameStartHandler
            .transform(input: .init(
                gameStarted: Observable.merge(
                    tutorialSeenStatusHandlerOutput.startGame,
                    gameStartAfterTutorialTrigger
                ))
            )
        
        let pistolSetSoundPlayed = gameStartHandlerOutput.playPistolSetSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        let gameTimerHandlerOutput = gameTimerHandler
            .transform(input: .init(
                timerStartTrigger: gameStartHandlerOutput.startTimer)
            )
        
        let startWhistleSoundPlayed = gameTimerHandlerOutput.playStartWhistleSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        let endWhistleSoundPlayed = gameTimerHandlerOutput.playEndWhistleSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        let timeCountUpdatingDisposable = gameTimerHandlerOutput.updateTimeCount
            .bind(to: state.timeCountRelay)
        
        let timerDisposed = gameTimerHandlerOutput.disposeTimer
            .do(onNext: { _ in
                timeCountUpdatingDisposable.dispose()
            })
        
        let firingMotionDetected = firingMoitonFilter
            .transform(input: .init(
                accelerationUpdated: input.inputFromDeviceMotion.accelerationUpdated,
                gyroUpdated: input.inputFromDeviceMotion.gyroUpdated)
            )
            .firingMotionDetected
        
        let reloadingMotionDetected = reloadingMotionFilter
            .transform(input: .init(
                gyroUpdated: input.inputFromDeviceMotion.gyroUpdated)
            )
            .reloadingMotionDetected
            .share()
        
        let weaponFireHandlerOutput = weaponFireHandler
            .transform(input: .init(
                weaponFiringTrigger: firingMotionDetected
                    .map({ [weak self] _ in self?.state.weaponTypeRelay.value ?? .pistol }),
                bulletsCount: state.bulletsCountRelay.asObservable()
            ))
        
        let noBulletsSoundPlayed = weaponFireHandlerOutput.playNoBulletsSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        let bulletsCountDecremented = weaponFireHandlerOutput.changeBulletsCount
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.state.bulletsCountRelay.accept($0)
            })
        
        let firingSoundPlayed = weaponFireHandlerOutput.playFiringSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        let weaponFireProcessCompleted = weaponFireHandlerOutput.weaponFireProcessCompleted
            .share()
        
        let reloadWeaponAutomatically = weaponAutoReloadFilter
            .transform(
                input: .init(
                    weaponFired: weaponFireProcessCompleted,
                    bulletsCount: state.bulletsCountRelay.asObservable()
                )
            )
            .reloadWeaponAutomatically
        
        let weaponReloadingTrigger = Observable
            .merge(
                reloadingMotionDetected
                    .map({ [weak self] _ in self?.state.weaponTypeRelay.value ?? .pistol }),
                reloadWeaponAutomatically
            )

        let weaponReloadHandlerOutput = weaponReloadHandler
            .transform(input: .init(
                weaponReloadingTrigger: weaponReloadingTrigger,
                bulletsCount: state.bulletsCountRelay.asObservable(),
                isWeaponReloading: state.isWeaponReloadingRelay.asObservable())
            )
        
        let bulletsCountRefilled = weaponReloadHandlerOutput.changeBulletsCount
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.state.bulletsCountRelay.accept($0)
            })
        
        let weaponReloadingFlagChanged = weaponReloadHandlerOutput.changeWeaponReloadingFlag
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.state.isWeaponReloadingRelay.accept($0)
            })
        
        let reloadingSoundPlayed = weaponReloadHandlerOutput.playReloadingSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        let weaponReloadProcessCompleted = weaponReloadHandlerOutput.weaponReloadProcessCompleted
        
        let weaponSelectHandlerOutput = weaponSelectHandler
            .transform(input: .init(weaponSelected: weaponSelectObserver.asObservable()))
        
        let weaponTypeChanged = weaponSelectHandlerOutput.changeWeaponType
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.state.weaponTypeRelay.accept($0)
            })
        
        let weaponChangingSoundPlayed = weaponSelectHandlerOutput.playWeaponChangingSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        let bulletsCountRefilledForNewWeapon = weaponSelectHandlerOutput.refillBulletsCountForNewWeapon
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.state.bulletsCountRelay.accept($0)
            })
        
        let weaponReloadingFlagChangedForNewWeapon = weaponSelectHandlerOutput.changeWeaponReloadingFlagForNewWeapon
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.state.isWeaponReloadingRelay.accept($0)
            })
        
        let weaponChangeProcessCompleted = weaponSelectHandlerOutput.weaponChangeProcessCompleted
            .share()
        
        let targetHitFilterOutput = targetHitFilter
            .transform(input: .init(collisionOccurred: input.inputFromARContent.collisionOccurred))
        
        let targetHitHandlerOutput = targetHitHandler
            .transform(input: .init(
                targetHit: targetHitFilterOutput.targetHit,
                currentScore: state.scoreRelay.asObservable())
            )
        
        let targetHitSoundPlayed = targetHitHandlerOutput.playTargetHitSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        let scoreUpdated = targetHitHandlerOutput.updateScore
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.state.scoreRelay.accept($0)
            })
        
        let weaponChangeViewShowed = input.inputFromView.weaponChangeButtonTapped
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showWeaponChangeView(
                    weaponSelectObserver: self.weaponSelectObserver
                )
            })
        
        let gameTimerDisposalHandlerOutput = gameTimerDisposalHandler
            .transform(input: .init(timerDisposed: timerDisposed))
        
        let weaponChangeViewDismissedOnTimerDisposal = gameTimerDisposalHandlerOutput.dismissWeaponChangeView
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismissWeaponChangeView()
            })
        
        let rankingAppearSoundPlayed = gameTimerDisposalHandlerOutput.playRankingAppearSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        let resultViewShowed = gameTimerDisposalHandlerOutput.showResultView
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showResultView(score: self.state.scoreRelay.value)
            })
        
        let reloadingMotionDetectionCounterOutput = reloadingMotionDetectionCounter
            .transform(input: .init(
                reloadingMotionDetected: reloadingMotionDetected,
                currentCount: state.reloadingMotionDetectedCountRelay.asObservable())
            )
        
        let reloadingMotionDetectedCountUpdated = reloadingMotionDetectionCounterOutput.updateCount
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.state.reloadingMotionDetectedCountRelay.accept($0)
            })
        
        let targetsAppearanceChangingSoundPlayed = reloadingMotionDetectionCounterOutput.playTargetsAppearanceChangingSound
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        
        // MARK: OutputToView
        let sightImageName = state.weaponTypeRelay
            .map({ $0.sightImageName })
        
        let sightImageColorHexCode = state.weaponTypeRelay
            .map({ $0.sightImageColorHexCode })
        
        let timeCountText = state.timeCountRelay
            .map({ TimeCountUtil.twoDigitTimeCount($0) })
        
        let bulletsCountImageName = state.bulletsCountRelay
            .map({ [weak self] in self?.state.weaponTypeRelay.value.bulletsCountImageName(at: $0) ?? "" })
        
        let isWeaponChangeButtonEnabled = state.timeCountRelay
            .map({ $0 < GameConst.timeCount && $0 > 0 })
        
        
        // MARK: OutputToARContent
        let setupSceneView = input.inputFromView.viewDidLoad
        
        let renderAllTargets = input.inputFromView.viewDidLoad
            .map({ _ in GameConst.targetCount })
        
        let startSceneSession = input.inputFromView.viewWillAppear
        
        let pauseSceneSession = input.inputFromView.viewWillDisappear
        
        let renderSelectedWeapon = Observable.merge(
            input.inputFromView.viewDidLoad
                .map({ [weak self] _ in self?.state.weaponTypeRelay.value ?? .pistol }),
            weaponChangeProcessCompleted
        )

        let renderWeaponFiring = weaponFireProcessCompleted
        
        let renderTargetsAppearanceChanging = reloadingMotionDetectionCounterOutput.detectionCountReachedTargetsAppearanceChangingLimit
        
        let moveWeaponToFPSPosition = input.inputFromARContent.rendererUpdated
            .map({ [weak self] _ in self?.state.weaponTypeRelay.value ?? .pistol })
        
        let removeContactedTargetAndBullet = targetHitHandlerOutput.removeContactedTargetAndBullet
        
        let renderTargetHitParticleToContactPoint = targetHitHandlerOutput.renderTargetHitParticleToContactPoint
        
        
        // MARK: OutputToDeviceMotion
        let startMotionDetection = gameStartHandlerOutput.startMotionDetection
        
        let stopMotionDetection = gameTimerDisposalHandlerOutput.stopMotionDetection

        
        return Output(
            viewModelAction: Output.ViewModelAction(
                pistolSetSoundPlayed: pistolSetSoundPlayed,
                startWhistleSoundPlayed: startWhistleSoundPlayed,
                firingSoundPlayed: firingSoundPlayed,
                noBulletsSoundPlayed: noBulletsSoundPlayed,
                reloadingSoundPlayed: reloadingSoundPlayed,
                targetHitSoundPlayed: targetHitSoundPlayed,
                targetsAppearanceChangingSoundPlayed: targetsAppearanceChangingSoundPlayed,
                weaponChangingSoundPlayed: weaponChangingSoundPlayed,
                endWhistleSoundPlayed: endWhistleSoundPlayed,
                rankingAppearSoundPlayed: rankingAppearSoundPlayed,
                bulletsCountDecremented: bulletsCountDecremented,
                bulletsCountRefilled: bulletsCountRefilled,
                bulletsCountRefilledForNewWeapon: bulletsCountRefilledForNewWeapon,
                weaponReloadingFlagChanged: weaponReloadingFlagChanged,
                weaponReloadingFlagChangedForNewWeapon: weaponReloadingFlagChangedForNewWeapon,
                weaponTypeChanged: weaponTypeChanged,
                scoreUpdated: scoreUpdated,
                reloadingMotionDetectedCountUpdated: reloadingMotionDetectedCountUpdated,
                tutorialViewShowed: tutorialViewShowed,
                weaponChangeViewShowed: weaponChangeViewShowed,
                weaponChangeViewDismissedOnTimerDisposal: weaponChangeViewDismissedOnTimerDisposal,
                resultViewShowed: resultViewShowed,
                weaponFireProcessCompleted: weaponFireProcessCompleted,
                weaponReloadProcessCompleted: weaponReloadProcessCompleted,
                weaponChangeProcessCompleted: weaponChangeProcessCompleted,
                timerDisposed: timerDisposed
            ),
            outputToView: Output.OutputToView(
                sightImageName: sightImageName,
                sightImageColorHexCode: sightImageColorHexCode,
                timeCountText: timeCountText,
                bulletsCountImageName: bulletsCountImageName,
                isWeaponChangeButtonEnabled: isWeaponChangeButtonEnabled
            ),
            outputToARContent: Output.OutputToARContent(
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
            outputToDeviceMotion: Output.OutputToDeviceMotion(
                startMotionDetection: startMotionDetection,
                stopMotionDetection: stopMotionDetection
            )
        )
    }
}



