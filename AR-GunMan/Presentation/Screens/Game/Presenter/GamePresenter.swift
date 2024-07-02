//
//  GamePresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 20/6/24.
//

import RxSwift
import RxCocoa

final class GamePresenter: PresenterType {
    struct ControllerEvents {
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
            let accelerationUpdated: Observable<Vector>
            let gyroUpdated: Observable<Vector>
        }
    }
    struct ViewModel {
        let outputToView: OutputToView
        let outputToARContent: OutputToARContent
        let outputToDeviceMotion: OutputToDeviceMotion
        
        struct OutputToView {
            let sightImageName: Driver<String>
            let sightImageColorHexCode: Driver<String>
            let timeCountText: Driver<String>
            let bulletsCountImageName: Driver<String>
            let isWeaponChangeButtonEnabled: Driver<Bool>
        }
        
        struct OutputToARContent {
            let setupSceneView: Driver<Void>
            let renderAllTargets: Driver<Int>
            let startSceneSession: Driver<Void>
            let pauseSceneSession: Driver<Void>
            let renderSelectedWeapon: Driver<WeaponType>
            let renderWeaponFiring: Driver<WeaponType>
            let renderTargetsAppearanceChanging: Driver<Void>
            let moveWeaponToFPSPosition: Driver<WeaponType>
            let removeContactedTargetAndBullet: Driver<(targetId: UUID, bulletId: UUID)>
            let renderTargetHitParticleToContactPoint: Driver<(weaponType: WeaponType, contactPoint: Vector)>
        }
        
        struct OutputToDeviceMotion {
            let startMotionDetection: Driver<Void>
            let stopMotionDetection: Driver<Void>
        }
    }
    class State {
        let timeCountRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
        let weaponTypeRelay = BehaviorRelay<WeaponType>(value: .pistol)
        let isWeaponReloadingRelay = BehaviorRelay<Bool>(value: false)
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        let scoreRelay = BehaviorRelay<Double>(value: 0)
        let reloadingMotionDetectedCountRelay = BehaviorRelay<Int>(value: 0)
    }
    
    private let gameUseCasesComposer: GameUseCasesComposerInterface
    private let navigator: GameNavigatorInterface
    private let state: State
    private let tutorialEndEventReceiver: PublishRelay<Void>
    private let weaponSelectEventReceiver: PublishRelay<WeaponType>
    private let disposeBag = DisposeBag()
    
    init(
        gameUseCasesComposer: GameUseCasesComposerInterface,
        navigator: GameNavigatorInterface,
        state: State = State(),
        tutorialEndEventReceiver: PublishRelay<Void> = PublishRelay<Void>(),
        weaponSelectEventReceiver: PublishRelay<WeaponType> = PublishRelay<WeaponType>()
    ) {
        self.gameUseCasesComposer = gameUseCasesComposer
        self.navigator = navigator
        self.state = state
        self.tutorialEndEventReceiver = tutorialEndEventReceiver
        self.weaponSelectEventReceiver = weaponSelectEventReceiver
    }
    
    func generateViewModel(from input: ControllerEvents) -> ViewModel {
        let composedGameUseCasesOutput = gameUseCasesComposer
            .transform(input: .init(
                tutorialNecessityCheckTrigger: input.inputFromView.viewDidAppear.take(1),
                tutorialEnded: tutorialEndEventReceiver.asObservable(),
                accelerationUpdated: input.inputFromDeviceMotion.accelerationUpdated,
                gyroUpdated: input.inputFromDeviceMotion.gyroUpdated,
                weaponSelected: weaponSelectEventReceiver.asObservable(),
                collisionOccurred: input.inputFromARContent.collisionOccurred,
                weaponType: state.weaponTypeRelay.asObservable(),
                bulletsCount: state.bulletsCountRelay.asObservable(),
                isWeaponReloading: state.isWeaponReloadingRelay.asObservable(),
                score: state.scoreRelay.asObservable(),
                reloadingMotionDetectedCount: state.reloadingMotionDetectedCountRelay.asObservable()
            ))
        
        disposeBag.insert {
            // MARK: State updates
            composedGameUseCasesOutput.updateTimeCount
                .bind(to: state.timeCountRelay)
            composedGameUseCasesOutput.updateWeaponType
                .bind(to: state.weaponTypeRelay)
            composedGameUseCasesOutput.updateWeaponReloadingFlag
                .bind(to: state.isWeaponReloadingRelay)
            composedGameUseCasesOutput.updateBulletsCount
                .bind(to: state.bulletsCountRelay)
            composedGameUseCasesOutput.updateScore
                .bind(to: state.scoreRelay)
            composedGameUseCasesOutput.updateReloadMotionDetectionCount
                .bind(to: state.reloadingMotionDetectedCountRelay)
            
            // MARK: Transitions
            composedGameUseCasesOutput.showTutorial
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showTutorialView(
                        tutorialEndEventReceiver: self.tutorialEndEventReceiver
                    )
                })
            input.inputFromView.weaponChangeButtonTapped
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showWeaponSelectView(
                        weaponSelectEventReceiver: self.weaponSelectEventReceiver
                    )
                })
            composedGameUseCasesOutput.dismissWeaponChangeView
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.dismissWeaponSelectView()
                })
            composedGameUseCasesOutput.showResultView
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showResultView(score: self.state.scoreRelay.value)
                })
        }

        return ViewModel(
            outputToView: .init(
                sightImageName: state.weaponTypeRelay
                    .map({ $0.sightImageName })
                    .asDriverOnErrorJustComplete(),
                sightImageColorHexCode: state.weaponTypeRelay
                    .map({ $0.sightImageColorHexCode })
                    .asDriverOnErrorJustComplete(),
                timeCountText: state.timeCountRelay
                    .map({ TimeCountUtil.twoDigitTimeCount($0) })
                    .asDriverOnErrorJustComplete(),
                bulletsCountImageName: state.bulletsCountRelay
                    .withLatestFrom(state.weaponTypeRelay) { ($0, $1) }
                    .map({ $1.bulletsCountImageName(at: $0) })
                    .asDriverOnErrorJustComplete(),
                isWeaponChangeButtonEnabled: state.timeCountRelay
                    .map({ $0 < GameConst.timeCount && $0 > 0 })
                    .asDriverOnErrorJustComplete()
            ),
            outputToARContent: .init(
                setupSceneView: input.inputFromView.viewDidLoad
                    .asDriverOnErrorJustComplete(),
                renderAllTargets: input.inputFromView.viewDidLoad
                    .map({ _ in GameConst.targetCount })
                    .asDriverOnErrorJustComplete(),
                startSceneSession: input.inputFromView.viewWillAppear
                    .asDriverOnErrorJustComplete(),
                pauseSceneSession: input.inputFromView.viewWillDisappear
                    .asDriverOnErrorJustComplete(),
                renderSelectedWeapon: composedGameUseCasesOutput.weaponChanged
                    .startWith(state.weaponTypeRelay.value)
                    .asDriverOnErrorJustComplete(),
                renderWeaponFiring: composedGameUseCasesOutput.weaponFired
                    .asDriverOnErrorJustComplete(),
                renderTargetsAppearanceChanging: composedGameUseCasesOutput.changeTargetsAppearance
                    .asDriverOnErrorJustComplete(),
                moveWeaponToFPSPosition: input.inputFromARContent.rendererUpdated
                    .withLatestFrom(state.weaponTypeRelay)
                    .asDriverOnErrorJustComplete(),
                removeContactedTargetAndBullet: composedGameUseCasesOutput.removeContactedTargetAndBullet
                    .asDriverOnErrorJustComplete(),
                renderTargetHitParticleToContactPoint: composedGameUseCasesOutput.renderTargetHitParticleToContactPoint
                    .asDriverOnErrorJustComplete()
            ),
            outputToDeviceMotion: .init(
                startMotionDetection: composedGameUseCasesOutput.startMotionDetection
                    .asDriverOnErrorJustComplete(),
                stopMotionDetection: composedGameUseCasesOutput.stopMotionDetection
                    .asDriverOnErrorJustComplete()
            )
        )
    }
}
