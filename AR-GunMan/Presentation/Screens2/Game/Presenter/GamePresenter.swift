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
    
    private let gameUseCasesComposer: GameUseCasesComposerInterface
    private let navigator: GameNavigatorInterface2
    private let state: State
    
    // 遷移先からの通知を受け取るレシーバー
    private let tutorialEndEventReceiver: PublishRelay<Void>
    private let weaponSelectEventReceiver: PublishRelay<WeaponType>
    
    private let disposeBag = DisposeBag()
    
    init(
        gameUseCasesComposer: GameUseCasesComposerInterface,
        navigator: GameNavigatorInterface2,
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
    
    func transform(input: GameControllerInput) -> GameViewModel2 {
        let composedGameUseCasesOutput = gameUseCasesComposer
            .transform(input: .init(
                tutorialNecessityCheckTrigger: input.inputFromViewController.viewDidAppear.take(1),
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
            input.inputFromViewController.weaponChangeButtonTapped
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showWeaponChangeView(
                        weaponSelectEventReceiver: self.weaponSelectEventReceiver
                    )
                })
            composedGameUseCasesOutput.dismissWeaponChangeView
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.dismissWeaponChangeView()
                })
            composedGameUseCasesOutput.showResultView
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showResultView(score: self.state.scoreRelay.value)
                })
        }

        return GameViewModel2(
            outputToView: GameViewModel2.OutputToView(
                sightImageName: state.weaponTypeRelay
                    .map({ $0.sightImageName }),
                sightImageColorHexCode: state.weaponTypeRelay
                    .map({ $0.sightImageColorHexCode }),
                timeCountText: state.timeCountRelay
                    .map({ TimeCountUtil.twoDigitTimeCount($0) }),
                bulletsCountImageName: state.bulletsCountRelay
                    .withLatestFrom(state.weaponTypeRelay) { ($0, $1) }
                    .map({ $1.bulletsCountImageName(at: $0) }),
                isWeaponChangeButtonEnabled: state.timeCountRelay
                    .map({ $0 < GameConst.timeCount && $0 > 0 })
            ),
            outputToARContent: GameViewModel2.OutputToARContent(
                setupSceneView: input.inputFromViewController.viewDidLoad,
                renderAllTargets: input.inputFromViewController.viewDidLoad
                    .map({ _ in GameConst.targetCount }),
                startSceneSession: input.inputFromViewController.viewWillAppear,
                pauseSceneSession: input.inputFromViewController.viewWillDisappear,
                renderSelectedWeapon: composedGameUseCasesOutput.weaponChanged
                    .startWith(state.weaponTypeRelay.value),
                renderWeaponFiring: composedGameUseCasesOutput.weaponFired,
                renderTargetsAppearanceChanging: composedGameUseCasesOutput.changeTargetsAppearance,
                moveWeaponToFPSPosition: input.inputFromARContent.rendererUpdated
                    .withLatestFrom(state.weaponTypeRelay),
                removeContactedTargetAndBullet: composedGameUseCasesOutput.removeContactedTargetAndBullet,
                renderTargetHitParticleToContactPoint: composedGameUseCasesOutput.renderTargetHitParticleToContactPoint
            ),
            outputToDeviceMotion: GameViewModel2.OutputToDeviceMotion(
                startMotionDetection: composedGameUseCasesOutput.startMotionDetection,
                stopMotionDetection: composedGameUseCasesOutput.stopMotionDetection
            )
        )
    }
}
