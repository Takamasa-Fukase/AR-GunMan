//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/1/23.
//

import RxSwift
import RxCocoa

final class GameViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewWillAppear: Observable<Void>
        let viewDidAppear: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let weaponChangeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let sceneView: Observable<UIView>
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
    
    private let useCase: GameUseCaseInterface
    private let navigator: GameNavigatorInterface
    
    private let disposeBag = DisposeBag()
    // 遷移先画面から受け取る通知
    private let tutorialEndObserver = PublishRelay<Void>()
    private let weaponSelectObserver = PublishRelay<WeaponType>()
    
    init(
        useCase: GameUseCaseInterface,
        navigator: GameNavigatorInterface
    ) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        // 画面が持つ状態
        var state = State()
        
        var timerObservable: Disposable?
        let autoReloadRelay = BehaviorRelay<Void>(value: Void())
        let startGameRelay = PublishRelay<Void>()
        
        timerObservable = startGameRelay
            .flatMapLatest({ [unowned self] in
                return self.useCase.startAccelerometerAndGyroUpdate()
            })
            .flatMapLatest({ [unowned self] in
                AudioUtil.playSound(of: .pistolSet)
                return self.useCase.awaitGameStartSignal()
            })
            .flatMapLatest({ [unowned self] in
                AudioUtil.playSound(of: .startWhistle)
                return self.useCase.getTimeCountStream()
            })
            .bind(to: state.timeCountRelay)
        
        input.viewDidLoad
            .flatMapLatest({ [unowned self] in
                return Observable.concat(
                    self.useCase.setupSceneViewAndNodes(),
                    self.useCase.showWeapon(.pistol).map({ _ in })
                )
            })
            .subscribe()
            .disposed(by: disposeBag)

        input.viewWillAppear
            .flatMapLatest({ [unowned self] in
                return self.useCase.startSession()
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        input.viewWillDisappear
            .flatMapLatest({ [unowned self] in
                return self.useCase.pauseSession()
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        input.viewDidAppear
            .take(1)
            .flatMapLatest { [unowned self] _ in
                return self.useCase.getIsTutorialSeen()
            }
            .subscribe(onNext: { [weak self] isSeen in
                guard let self = self else { return }
                if isSeen {
                    startGameRelay.accept(Void())
                }else {
                    self.navigator.showTutorialView(
                        tutorialEndObserver: self.tutorialEndObserver
                    )
                }
            }).disposed(by: disposeBag)
        
        input.weaponChangeButtonTapped
            .filter({ _ in state.isPlaying })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showWeaponChangeView(
                    weaponSelectObserver: self.weaponSelectObserver
                )
            }).disposed(by: disposeBag)
        
        tutorialEndObserver
            .flatMapLatest({ [unowned self] in
                // チュートリアル通過フラグをセットする
                return self.useCase.setTutorialAlreadySeen()
            })
            .subscribe(onNext: { _ in
                startGameRelay.accept(Void())
            }).disposed(by: disposeBag)
        
        weaponSelectObserver
            .flatMapLatest({ [unowned self] weaponType in
                return self.useCase.showWeapon(weaponType)
            })
            .subscribe(onNext: { weaponType in
                state.weaponTypeRelay.accept(weaponType)
                AudioUtil.playSound(of: weaponType.weaponChangingSound)
                state.bulletsCountRelay.accept(
                    weaponType.bulletsCapacity
                )
                state.isWeaponReloading = false
            }).disposed(by: disposeBag)
        
        state.timeCountRelay
            .filter({$0 <= 0})
            .flatMapLatest({ [unowned self] _ in
                AudioUtil.playSound(of: .endWhistle)
                timerObservable?.dispose()
                self.navigator.dismissWeaponChangeView()
                return self.useCase.stopAccelerometerAndGyroUpdate()
            })
            .flatMapLatest({ [unowned self] in
                return self.useCase.awaitShowResultSignal()
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                AudioUtil.playSound(of: .rankingAppear)
                self.navigator.showResultView(totalScore: state.score)
            }).disposed(by: disposeBag)

        useCase.getTargetHitStream()
            .subscribe(onNext: { _ in
                AudioUtil.playSound(of: state.weaponTypeRelay.value.hitSound)
                state.score = ScoreCalculator.getTotalScore(
                    currentScore: state.score,
                    weaponType: state.weaponTypeRelay.value
                )
            }).disposed(by: disposeBag)
        
        useCase.getFiringMotionStream()
            .filter({ _ in
                guard state.isPlaying else { return false }
                guard state.canFire else {
                    if state.weaponTypeRelay.value.reloadType == .manual {
                        AudioUtil.playSound(of: .pistolOutBullets)
                    }
                    return false
                }
                return true
            })
            .flatMapLatest({ [unowned self] _ in
                return self.useCase.fireWeapon()
            })
            .subscribe(onNext: { _ in
                AudioUtil.playSound(of: state.weaponTypeRelay.value.firingSound)
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
                useCase.getReloadingMotionStream()
                    .map({ _ in
                        // リロードモーションの検知回数をインクリメントする
                        state.reloadingMotionDetectedCountRelay.accept(
                            state.reloadingMotionDetectedCountRelay.value + 1
                        )
                    })
            )
            .filter({ _ in
                return state.isPlaying && state.canReload
            })
            .flatMapLatest({ [unowned self] _ in
                state.isWeaponReloading = true
                AudioUtil.playSound(of: state.weaponTypeRelay.value.reloadingSound)
                return self.useCase.awaitWeaponReloadEnds(currentWeapon: state.weaponTypeRelay.value)
            })
            .subscribe(onNext: { _ in
                state.bulletsCountRelay.accept(
                    state.weaponTypeRelay.value.bulletsCapacity
                )
                state.isWeaponReloading = false
            }).disposed(by: disposeBag)
        
        state.reloadingMotionDetectedCountRelay
            .filter({ $0 == 20 && state.isPlaying })
            .flatMapLatest({ [unowned self] _ in
                return self.useCase.executeSecretEvent()
            })
            .subscribe(onNext: { _ in
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
            sceneView: useCase.getSceneView(),
            sightImage: sightImage,
            sightImageColor: sightImageColor,
            timeCountText: timeCountText,
            bulletsCountImage: bulletsCountImage
        )
    }
}
