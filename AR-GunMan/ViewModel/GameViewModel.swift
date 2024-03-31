//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/1/23.
//

import RxSwift
import RxCocoa

class GameViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewWillAppear: Observable<Void>
        let viewDidAppear: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let weaponChangeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let sightImage: Observable<UIImage?>
        let sightImageColor: Observable<UIColor>
        let timeCountText: Observable<String>
        let bulletsCountImage: Observable<UIImage?>
    }
    
    struct State {
        let weaponTypeRelay = BehaviorRelay<WeaponType>(value: .pistol)
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        var isWeaponReloading: Bool = false
        let timeCountRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
        var score: Double = 0
        var reloadingMotionDetectedCountRelay = BehaviorRelay<Int>(value: 0)
    }
    
    struct Dependency {
        let tutorialRepository: TutorialRepository
        let useCase: GameUseCase
        let navigator: GameNavigatorInterface
        let sceneManager: GameSceneManager
    }
    
    private let tutorialRepository: TutorialRepository
    private let useCase: GameUseCase
    private let navigator: GameNavigatorInterface
    private let sceneManager: GameSceneManager
    private let disposeBag = DisposeBag()
    
    init(dependency: Dependency) {
        self.tutorialRepository = dependency.tutorialRepository
        self.useCase = dependency.useCase
        self.navigator = dependency.navigator
        self.sceneManager = dependency.sceneManager
    }
    
    func transform(input: Input) -> Output {
        // 画面が持つ状態
        var state = State()
        
        var timerObservable: Disposable?
        
        // 遷移先画面から受け取る通知
        let tutorialEndObserver = PublishRelay<Void>()
        let weaponSelectObserver = PublishRelay<WeaponType>()
        
        let autoReloadRelay = BehaviorRelay<Void>(value: Void())
        
        // 仮置き
        func startGame() {
            AudioUtil.playSound(of: .pistolSet)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                AudioUtil.playSound(of: .startWhistle)
                timerObservable = TimeCountUtil.createRxTimer(.milliseconds(10))
                    .map({ _ in
                        TimeCountUtil.decreaseGameTimeCount(lastValue: state.timeCountRelay.value)
                    })
                    .bind(to: state.timeCountRelay)
                self.useCase.startAccelerometerAndGyroUpdate()
            }
        }
        
        func countReloadingMotion() {
            // リロードモーションの検知回数をインクリメントする
            state.reloadingMotionDetectedCountRelay.accept(
                state.reloadingMotionDetectedCountRelay.value + 1
            )
        }
        
        input.viewDidLoad
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.sceneManager.injectSceneViewIntoVC()
            }).disposed(by: disposeBag)
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.sceneManager.startSession()
            }).disposed(by: disposeBag)
        
        input.viewWillDisappear
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.sceneManager.pauseSession()
            }).disposed(by: disposeBag)
        
        input.viewDidAppear
            .take(1)
            .flatMapLatest { [unowned self] _ in
                return self.tutorialRepository.getIsTutorialSeen()
            }
            .subscribe(onNext: { [weak self] isSeen in
                guard let self = self else { return }
                if isSeen {
                    startGame()
                }else {
                    self.navigator.showTutorialView(
                        tutorialEndObserver: tutorialEndObserver
                    )
                }
            }).disposed(by: disposeBag)
        
        input.weaponChangeButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showWeaponChangeView(
                    weaponSelectObserver: weaponSelectObserver
                )
            }).disposed(by: disposeBag)
        
        tutorialEndObserver
            .subscribe(onNext: { _ in
                startGame()
            }).disposed(by: disposeBag)
        
        weaponSelectObserver
            .subscribe(onNext: { weaponType in
                state.weaponTypeRelay.accept(weaponType)
                AudioUtil.playSound(of: weaponType.weaponChangingSound)
                state.bulletsCountRelay.accept(
                    weaponType.bulletsCapacity
                )
                state.isWeaponReloading = false
            }).disposed(by: disposeBag)
        
        state.weaponTypeRelay
            .subscribe(onNext: { [weak self] weaponType in
                guard let self = self else { return }
                self.sceneManager.showWeapon(weaponType)
            }).disposed(by: disposeBag)
        
        state.timeCountRelay
            .filter({$0 <= 0})
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                AudioUtil.playSound(of: .endWhistle)
                timerObservable?.dispose()
                useCase.stopAccelerometerAndGyroUpdate()
                self.navigator.dismissWeaponChangeView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    AudioUtil.playSound(of: .rankingAppear)
                    self.navigator.showResultView(totalScore: state.score)
                })
            }).disposed(by: disposeBag)
        
        sceneManager.targetHit
            .subscribe(onNext: { _ in
                AudioUtil.playSound(of: state.weaponTypeRelay.value.hitSound)
                state.score = ScoreCalculator.getTotalScore(
                    currentScore: state.score,
                    weaponType: state.weaponTypeRelay.value
                )
            }).disposed(by: disposeBag)
        
        useCase.getFiringMotionStream()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard self.canFire(bulletsCount: state.bulletsCountRelay.value) else {
                    if state.weaponTypeRelay.value.reloadType == .manual {
                        AudioUtil.playSound(of: .pistolOutBullets)
                    }
                    return
                }
                AudioUtil.playSound(of: state.weaponTypeRelay.value.firingSound)
                self.sceneManager.fireWeapon()
                state.bulletsCountRelay.accept(
                    state.bulletsCountRelay.value - 1
                )
                if state.weaponTypeRelay.value.reloadType == .auto {
                    autoReloadRelay.accept(Void())
                }
            }).disposed(by: disposeBag)

        // 自動リロードトリガーとモーション検知のどちらでも発火させる為combineしている
        Observable
            .combineLatest(
                autoReloadRelay.asObservable(),
                useCase.getReloadingMotionStream().map({ _ in countReloadingMotion() })
            )
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard self.canReload(bulletsCount: state.bulletsCountRelay.value,
                                     isWeaponReloading: state.isWeaponReloading) else { return }
                state.isWeaponReloading = true
                AudioUtil.playSound(of: state.weaponTypeRelay.value.reloadingSound)
                DispatchQueue.main.asyncAfter(deadline: state.weaponTypeRelay.value.reloadDuration,
                                              execute: {
                    state.bulletsCountRelay.accept(
                        state.weaponTypeRelay.value.bulletsCapacity
                    )
                    state.isWeaponReloading = false
                })
            }).disposed(by: disposeBag)
        
        state.reloadingMotionDetectedCountRelay
            .filter({ $0 == 20 })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.sceneManager.changeTargetsToTaimeisan()
                AudioUtil.playSound(of: .kyuiin)
            }).disposed(by: disposeBag)
        
        // MARK: Outputの作成
        let sightImage = state.weaponTypeRelay
            .map({$0.sightImage})
        
        let sightImageColor = state.weaponTypeRelay
            .map({$0.sightImageColor})
        
        let timeCountText = state.timeCountRelay
            .map({TimeCountUtil.twoDigitTimeCount($0)})
        
        let bulletsCountImage = state.bulletsCountRelay
            .map({state.weaponTypeRelay.value.bulletsCountImage(at: $0)})
        
        return Output(
            sightImage: sightImage,
            sightImageColor: sightImageColor,
            timeCountText: timeCountText,
            bulletsCountImage: bulletsCountImage
        )
    }
    
    private func canFire(bulletsCount: Int) -> Bool {
        return bulletsCount > 0
    }
    
    private func canReload(bulletsCount: Int, isWeaponReloading: Bool) -> Bool {
        return bulletsCount <= 0 && !isWeaponReloading
    }
}
