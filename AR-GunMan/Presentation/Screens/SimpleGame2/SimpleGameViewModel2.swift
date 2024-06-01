//
//  SimpleGameViewModel2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/5/24.
//

import RxSwift
import RxCocoa

final class SimpleGameViewModel2: ViewModelType {
    struct Input {
        let inputFromView: InputFromView
        let inputFromGameScene: InputFromGameScene
        let inputFromCoreMotion: InputFromCoreMotion

        struct InputFromView {
            let viewDidAppear: Observable<Void>
            let weaponChangeButtonTapped: Observable<Void>
        }
        
        struct InputFromGameScene {
            let targetHit: Observable<Void>
        }
        
        struct InputFromCoreMotion {
            let accelerationUpdated: Observable<(x: Double, y: Double, z: Double)>
            let gyroUpdated: Observable<(x: Double, y: Double, z: Double)>
        }
    }
    
    struct Output {
        let viewModelAction: ViewModelAction
        let outputToView: OutputToView
        let outputToGameScene: OutputToGameScene
        
        struct ViewModelAction {
            let noBulletsSoundPlayed: Observable<SoundType>
            let bulletsCountDecremented: Observable<Int>
            let firingSoundPlayed: Observable<SoundType>
            let weaponFired: Observable<WeaponType>
            let bulletsCountRefilled: Observable<Int>
            let weaponReloadingFlagChanged: Observable<Bool>
            let reloadingSoundPlayed: Observable<SoundType>
            let weaponReloaded: Observable<WeaponType>
            let weaponTypeChanged: Observable<WeaponType>
            let weaponChangingSoundPlayed: Observable<SoundType>
            let bulletsCountRefilledForNewWeapon: Observable<Int>
            let weaponReloadingFlagChangedForNewWeapon: Observable<Bool>
            let weaponChanged: Observable<WeaponType>
            let targetHitSoundPlayed: Observable<SoundType>
            let scoreUpdated: Observable<Double>
        }
        
        struct OutputToView {
            let bulletsCountImage: Observable<UIImage?>
        }
        
        struct OutputToGameScene {
            let renderSelectedWeapon: Observable<WeaponType>
            let renderWeaponFiring: Observable<WeaponType>
        }
    }
    
    class State {
        let weaponTypeRelay = BehaviorRelay<WeaponType>(value: .pistol)
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        var isWeaponReloadingRelay = BehaviorRelay<Bool>(value: false)
        let scoreRelay = BehaviorRelay<Double>(value: 0)
    }

    private let useCase: GameUseCase2Interface
    private let tutorialEndObserver: PublishRelay<Void>
    private let weaponSelectObserver: PublishRelay<WeaponType>
    private let tutorialSeenStatusHandler: TutorialSeenStatusHandler
    private let gameStartHandler: GameStartHandler
    private let firingMoitonFilter: FiringMotionFilter
    private let reloadingMotionFilter: ReloadingMotionFilter
    private let weaponFireHandler: WeaponFireHandler
    private let weaponAutoReloadHandler: WeaponAutoReloadHandler
    private let weaponReloadHandler: WeaponReloadHandler
    private let weaponSelectHandler: WeaponSelectHandler
    private let targetHitHandler: TargetHitHandler
    private let state: State
    private let soundPlayer: SoundPlayerInterface
    
    init(
        useCase: GameUseCase2Interface,
        tutorialEndObserver: PublishRelay<Void> = PublishRelay<Void>(),
        weaponSelectObserver: PublishRelay<WeaponType> = PublishRelay<WeaponType>(),
        tutorialSeenStatusHandler: TutorialSeenStatusHandler,
        gameStartHandler: GameStartHandler,
        firingMoitonFilter: FiringMotionFilter,
        reloadingMotionFilter: ReloadingMotionFilter,
        weaponFireHandler: WeaponFireHandler,
        weaponAutoReloadHandler: WeaponAutoReloadHandler,
        weaponReloadHandler: WeaponReloadHandler,
        weaponSelectHandler: WeaponSelectHandler,
        targetHitHandler: TargetHitHandler,
        state: State = State(),
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared
    ) {
        self.useCase = useCase
        self.tutorialEndObserver = tutorialEndObserver
        self.weaponSelectObserver = weaponSelectObserver
        self.tutorialSeenStatusHandler = tutorialSeenStatusHandler
        self.gameStartHandler = gameStartHandler
        self.firingMoitonFilter = firingMoitonFilter
        self.reloadingMotionFilter = reloadingMotionFilter
        self.weaponFireHandler = weaponFireHandler
        self.weaponAutoReloadHandler = weaponAutoReloadHandler
        self.weaponReloadHandler = weaponReloadHandler
        self.weaponSelectHandler = weaponSelectHandler
        self.targetHitHandler = targetHitHandler
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
                // TODO: navigator経由でチュートリアルの表示指示
            })
        
        let gameStartAfterTutorialTrigger = tutorialEndObserver
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.useCase.setTutorialAlreadySeen()
            })
        
        let startGameHandlerOutput = gameStartHandler
            .transform(input: .init(
                gameStarted: Observable.merge(
                    tutorialSeenStatusHandlerOutput.startGame,
                    gameStartAfterTutorialTrigger
                ))
            )
        
        let firingMotionDetected = firingMoitonFilter
            .transform(input: .init(
                accelerationUpdated: input.inputFromCoreMotion.accelerationUpdated,
                gyroUpdated: input.inputFromCoreMotion.gyroUpdated)
            )
            .firingMotionDetected
        
        let reloadingMotionDetected = reloadingMotionFilter
            .transform(input: .init(
                gyroUpdated: input.inputFromCoreMotion.gyroUpdated)
            )
            .reloadingMotionDetected
        
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
        
        let weaponFired = weaponFireHandlerOutput.weaponFired
            .share()
        
        let weaponAutoReloadTrigger = weaponAutoReloadHandler
            .transform(
                input: .init(weaponFired: weaponFired
                    .withLatestFrom(state.bulletsCountRelay) { ($0, $1) })
            )
            .weaponAutoReloadTrigger
        
        let weaponReloadingTrigger = Observable
            .merge(
                reloadingMotionDetected
                    .map({ [weak self] _ in self?.state.weaponTypeRelay.value ?? .pistol }),
                weaponAutoReloadTrigger
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
        
        let weaponReloaded = weaponReloadHandlerOutput.weaponReloaded
        
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
        
        let weaponChanged = weaponSelectHandlerOutput.weaponChanged
            .share()
        
        let targetHitHandlerOutput = targetHitHandler
            .transform(input: .init(
                targetHit: input.inputFromGameScene.targetHit
                    .map({ [weak self] _ in self?.state.weaponTypeRelay.value ?? .pistol }),
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
            
        
        // MARK: OutputToView
        let bulletsCountImage = state.bulletsCountRelay
            .map({ [weak self] in self?.state.weaponTypeRelay.value.bulletsCountImage(at: $0) })
        
        
        // MARK: OutputToGameScene
        let renderSelectedWeapon = weaponChanged

        let renderWeaponFiring = weaponFired

        
        return Output(
            viewModelAction: Output.ViewModelAction(
                noBulletsSoundPlayed: noBulletsSoundPlayed,
                bulletsCountDecremented: bulletsCountDecremented,
                firingSoundPlayed: firingSoundPlayed,
                weaponFired: weaponFired,
                bulletsCountRefilled: bulletsCountRefilled,
                weaponReloadingFlagChanged: weaponReloadingFlagChanged,
                reloadingSoundPlayed: reloadingSoundPlayed,
                weaponReloaded: weaponReloaded,
                weaponTypeChanged: weaponTypeChanged,
                weaponChangingSoundPlayed: weaponChangingSoundPlayed,
                bulletsCountRefilledForNewWeapon: bulletsCountRefilledForNewWeapon,
                weaponReloadingFlagChangedForNewWeapon: weaponReloadingFlagChangedForNewWeapon,
                weaponChanged: weaponChanged,
                targetHitSoundPlayed: targetHitSoundPlayed,
                scoreUpdated: scoreUpdated
            ),
            outputToView: Output.OutputToView(
                bulletsCountImage: bulletsCountImage
            ),
            outputToGameScene: Output.OutputToGameScene(
                renderSelectedWeapon: renderSelectedWeapon,
                renderWeaponFiring: renderWeaponFiring
            )
        )
    }
}



