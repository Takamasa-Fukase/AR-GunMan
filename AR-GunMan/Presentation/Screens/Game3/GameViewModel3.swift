//
//  GameViewModel3.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/23.
//

import RxSwift
import RxCocoa

final class GameViewModel3: ViewModelType {
    struct Input {
        let inputFromView: InputFromView
        let inputFromGameScene: InputFromGameScene
        let inputFromCoreMotion: InputFromCoreMotion
        
        struct InputFromView {
            let viewDidLoad: Observable<Void>
            let viewWillAppear: Observable<Void>
            let viewDidAppear: Observable<Void>
            let viewWillDisappear: Observable<Void>
            let weaponChangeButtonTapped: Observable<Void>
        }
        
        struct InputFromGameScene {
            let rendererUpdated: Observable<Void>
            let targetHit: Observable<Void>
        }
        
        struct InputFromCoreMotion {
            let accelerationUpdated: Observable<(x: Double, y: Double, z: Double)>
            let gyroUpdated: Observable<(x: Double, y: Double, z: Double)>
        }
    }
    
    struct Output {
        let outputToView: OutputToView
        let outputToGameScene: OutputToGameScene
        let outputToCoreMotion: OutputToCoreMotion
        let viewModelAction: ViewModelAction
        
        struct OutputToView {
            let sightImage: Observable<UIImage?>
            let sightImageColor: Observable<UIColor>
            let timeCountText: Observable<String>
            let bulletsCountImage: Observable<UIImage?>
        }
        
        struct OutputToGameScene {
            let setupSceneView: Observable<Void>
            let renderAllTargets: Observable<Int>
            let startSceneSession: Observable<Void>
            let pauseSceneSession: Observable<Void>
            let renderSelectedWeapon: Observable<WeaponType>
            let renderWeaponFiring: Observable<WeaponType>
            let renderTargetsAppearanceChanging: Observable<Void>
            let moveWeaponToFPSPosition: Observable<WeaponType>
        }
        
        struct OutputToCoreMotion {
            let startMotionDetection: Observable<Void>
            let stopMotionDetection: Observable<Void>
        }
        
        struct ViewModelAction {
            let startGame: Observable<Void>
            let showTutorialView: Observable<Void>
            let startGameAfterTutorial: Observable<Void>
            let fireWeapon: Observable<Void>
            let reloadWeapon: Observable<Void>
            let changeWeapon: Observable<Void>
            let countScore: Observable<Void>
            let showWeaponChangeView: Observable<Void>
            let dismissWeaponChangeView: Observable<Void>
            let showResultView: Observable<Void>
        }
    }
    
    struct State {
        let weaponTypeRelay = BehaviorRelay<WeaponType>(value: .pistol)
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        let isWeaponReloadingRelay = BehaviorRelay<Bool>(value: false)
        let timeCountRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
        let scoreRelay = BehaviorRelay<Double>(value: 0)
        let reloadingMotionDetectedCountRelay = BehaviorRelay<Int>(value: 0)
        var isPlaying: Bool {
            return timeCountRelay.value < GameConst.timeCount && timeCountRelay.value > 0
        }
        var canFire: Bool {
            return bulletsCountRelay.value > 0
        }
        var canReload: Bool {
            return bulletsCountRelay.value <= 0 && !isWeaponReloading
        }
    }
    
    private let useCase: GameUseCase3Interface
    private let navigator: GameNavigator3Interface
    private let state: State
    private let soundPlayer: SoundPlayerInterface
    private let tutorialEndObserver: PublishRelay<Void>
    private let weaponSelectObserver: PublishRelay<WeaponType>
    
    init(
        useCase: GameUseCase3Interface,
        navigator: GameNavigator3Interface,
        state: State = State(),
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared,
        tutorialEndObserver: PublishRelay<Void> = PublishRelay<Void>(),
        weaponSelectObserver: PublishRelay<WeaponType> = PublishRelay<WeaponType>()
    ) {
        self.useCase = useCase
        self.navigator = navigator
        self.state = state
        self.soundPlayer = soundPlayer
        self.tutorialEndObserver = tutorialEndObserver
        self.weaponSelectObserver = weaponSelectObserver
    }
    
    func transform(input: Input) -> Output {
        let autoReloadRelay = BehaviorRelay<Void>(value: Void())
        let startGameRelay = PublishRelay<Void>()
        
        let timerStartTrigger = startGameRelay
            .flatMapLatest({ [unowned self] in
                AudioUtil.playSound(of: .pistolSet)
                return self.useCase.awaitTimerStartSignal()
            })

        let timerDisposable = timerStartTrigger
            .flatMapLatest({ [unowned self] in
                AudioUtil.playSound(of: .startWhistle)
                return self.useCase.getTimeCountStream()
            })
            .bind(to: state.timeCountRelay)
        
        let isTutorialSeen = input.inputFromView.viewDidAppear
            .take(1)
            .flatMapLatest { [unowned self] _ in self.useCase.getIsTutorialSeen() }
        
        let firingMotionDetected = CoreMotionStreamFilter
            .filterFiringMotionStream(
                accelerationStream: input.inputFromCoreMotion.accelerationUpdated,
                gyroStream: input.inputFromCoreMotion.gyroUpdated
            )
        
        let weaponFiringTrigger = firingMotionDetected
            .map({ _ in state.weaponTypeRelay.value })
            .filter({ weaponType in
                guard state.isPlaying else { return false }
                guard state.canFire else {
                    if weaponType.reloadType == .manual {
                        AudioUtil.playSound(of: .pistolOutBullets)
                    }
                    return false
                }
                return true
            })
        
        let reloadingMotionDetected = CoreMotionStreamFilter
            .filterReloadingMotionStream(
                gyroStream: input.inputFromCoreMotion.gyroUpdated
            )
            .map({ _ in
                // リロードモーションの検知回数をインクリメントする
                state.reloadingMotionDetectedCountRelay.accept(
                    state.reloadingMotionDetectedCountRelay.value + 1
                )
            })
        
        // 自動リロードトリガーとモーション検知のどちらでも発火させる為combineしている
        let weaponReloadingTrigger = Observable
            .combineLatest(
                autoReloadRelay.asObservable(),
                reloadingMotionDetected
            )
            .map({ _ in state.weaponTypeRelay.value })
            .filter({ _ in state.isPlaying && state.canReload })

        let timeCountEnded = state.timeCountRelay
            .filter({$0 <= 0})
            .map({ _ in
                AudioUtil.playSound(of: .endWhistle)
                timerDisposable.dispose()
            })
        
        
        // MARK: OutputToView
        let sightImage = state.weaponTypeRelay
            .map({ $0.sightImage })
        
        let sightImageColor = state.weaponTypeRelay
            .map({ $0.sightImageColor })
        
        let timeCountText = state.timeCountRelay
            .map({ TimeCountUtil.twoDigitTimeCount($0) })
        
        let bulletsCountImage = state.bulletsCountRelay
            .map({ state.weaponTypeRelay.value.bulletsCountImage(at: $0) })
        
        
        // MARK: OutputToGameScene
        let setupSceneView = input.inputFromView.viewDidLoad
        
        let renderAllTargets = input.inputFromView.viewDidLoad
            .map({ _ in GameConst.targetCount })
        
        let startSceneSession = input.inputFromView.viewWillAppear
        
        let pauseSceneSession = input.inputFromView.viewWillDisappear
        
        let renderSelectedWeapon = weaponSelectObserver.asObservable()
        
        let renderWeaponFiring = weaponFiringTrigger

        // TODO: 20をconstにする
        let renderTargetsAppearanceChanging = state.reloadingMotionDetectedCountRelay
            .filter({ $0 == 20 && state.isPlaying })
            .map({ _ in AudioUtil.playSound(of: .kyuiin) })
        
        let moveWeaponToFPSPosition = input.inputFromGameScene.rendererUpdated
            .map({ _ in state.weaponTypeRelay.value })
        
        
        // MARK: OutputToCoreMotion
        let startMotionDetection = startGameRelay.asObservable()

        let stopMotionDetection = timeCountEnded
        
        
        // MARK: ViewModelAction
        let startGame = isTutorialSeen
            .filter({ $0 })
            .map({ _ in })
            .do(onNext: { _ in startGameRelay.accept(Void()) })
        
        let showTutorialView = isTutorialSeen
            .filter({ !$0 })
            .map({ _ in })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showTutorialView(
                    tutorialEndObserver: self.tutorialEndObserver
                )
            })
        
        let startGameAfterTutorial = tutorialEndObserver
            .flatMapLatest({ [unowned self] in
                // チュートリアル通過フラグをセットする
                return self.useCase.setTutorialAlreadySeen()
            })
            .do(onNext: { _ in startGameRelay.accept(Void()) })
        
        let fireWeapon = weaponFiringTrigger
            .do(onNext: { weaponType in
                AudioUtil.playSound(of: weaponType.firingSound)
                state.bulletsCountRelay.accept(
                    state.bulletsCountRelay.value - 1
                )
                if weaponType.reloadType == .auto {
                    autoReloadRelay.accept(Void())
                }
            })
            .map({ _ in })
        
        let reloadWeapon = weaponReloadingTrigger
            .flatMapLatest({ [unowned self] weaponType in
                state.isWeaponReloading = true
                AudioUtil.playSound(of: weaponType.reloadingSound)
                return self.useCase.awaitWeaponReloadEnds(currentWeapon: state.weaponTypeRelay.value)
            })
            .filter({ _ in state.isWeaponReloading })
            .do(onNext: { weaponType in
                state.bulletsCountRelay.accept(
                    weaponType.bulletsCapacity
                )
                state.isWeaponReloading = false
            })
            .map({ _ in })
        
        let changeWeapon = weaponSelectObserver
            .do(onNext: { weaponType in
                state.weaponTypeRelay.accept(weaponType)
                AudioUtil.playSound(of: weaponType.weaponChangingSound)
                state.bulletsCountRelay.accept(
                    weaponType.bulletsCapacity
                )
                state.isWeaponReloading = false
            })
            .map({ _ in })
        
        let countScore = input.inputFromGameScene.targetHit
            .do(onNext: { _ in
                AudioUtil.playSound(of: state.weaponTypeRelay.value.hitSound)
                state.score = ScoreCalculator.getTotalScore(
                    currentScore: state.score,
                    weaponType: state.weaponTypeRelay.value
                )
            })
        
        let showWeaponChangeView = input.inputFromView.weaponChangeButtonTapped
            .filter({ _ in state.isPlaying })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showWeaponChangeView(
                    weaponSelectObserver: self.weaponSelectObserver
                )
            })
        
        let dismissWeaponChangeView = timeCountEnded
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismissWeaponChangeView()
            })
        
        let showResultView = timeCountEnded
            .flatMapLatest({ [unowned self] in
                return self.useCase.awaitShowResultSignal()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                AudioUtil.playSound(of: .rankingAppear)
                self.navigator.showResultView(totalScore: state.score)
            })
        
        return Output(
            outputToView: Output.OutputToView(
                sightImage: sightImage,
                sightImageColor: sightImageColor,
                timeCountText: timeCountText,
                bulletsCountImage: bulletsCountImage
            ),
            outputToGameScene: Output.OutputToGameScene(
                setupSceneView: setupSceneView,
                renderAllTargets: renderAllTargets,
                startSceneSession: startSceneSession,
                pauseSceneSession: pauseSceneSession,
                renderSelectedWeapon: renderSelectedWeapon,
                renderWeaponFiring: renderWeaponFiring,
                renderTargetsAppearanceChanging: renderTargetsAppearanceChanging,
                moveWeaponToFPSPosition: moveWeaponToFPSPosition
            ),
            outputToCoreMotion: Output.OutputToCoreMotion(
                startMotionDetection: startMotionDetection,
                stopMotionDetection: stopMotionDetection
            ),
            viewModelAction: Output.ViewModelAction(
                startGame: startGame,
                showTutorialView: showTutorialView,
                startGameAfterTutorial: startGameAfterTutorial,
                fireWeapon: fireWeapon,
                reloadWeapon: reloadWeapon,
                changeWeapon: changeWeapon,
                countScore: countScore,
                showWeaponChangeView: showWeaponChangeView,
                dismissWeaponChangeView: dismissWeaponChangeView,
                showResultView: showResultView
            )
        )
    }
}


