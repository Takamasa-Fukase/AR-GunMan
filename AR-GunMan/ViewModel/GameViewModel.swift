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
        let viewDidAppear: Observable<Void>
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
        var isBazookaReloading: Bool = false
        let timeCountRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
        var score: Double = 0
    }
    
    private let tutorialRepository: TutorialRepository
    private let navigator: GameNavigatorInterface
    private let disposeBag = DisposeBag()
    
    init(tutorialRepository: TutorialRepository,
         navigator: GameNavigatorInterface) {
        self.tutorialRepository = tutorialRepository
        self.navigator = navigator
    }
    
    func transform(
        input: Input,
        sceneManager: GameSceneManager
    ) -> Output {
        var state = State()
        let motionDetector = MotionDetector()
        var timerObservable: Disposable?
        let tutorialEndObserver = PublishRelay<Void>()
        let weaponSelectObserver = PublishRelay<WeaponType>()
        
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
            }
        }
        
        tutorialEndObserver
            .subscribe(onNext: { _ in
                startGame()
            }).disposed(by: disposeBag)
        
        weaponSelectObserver
            .subscribe(onNext: { [weak self] weaponType in
                guard let self = self else { return }
                state.weaponTypeRelay.accept(weaponType)
                self.navigator.dismissWeaponChangeView()
                AudioUtil.playSound(of: weaponType.weaponChangingSound)
                state.bulletsCountRelay.accept(
                    weaponType.bulletsCapacity
                )
                state.isBazookaReloading = false
            }).disposed(by: disposeBag)
        
        state.weaponTypeRelay
            .subscribe(onNext: { weaponType in
                sceneManager.showWeapon(weaponType)
            }).disposed(by: disposeBag)
        
        sceneManager.targetHit
            .subscribe(onNext: { _ in
                AudioUtil.playSound(of: state.weaponTypeRelay.value.hitSound)
                state.score = ScoreCalculator.getTotalScore(
                    currentScore: state.score,
                    weaponType: state.weaponTypeRelay.value
                )
            }).disposed(by: disposeBag)
        
        motionDetector.firingMotionDetected
            .subscribe(onNext: { _ in
                guard self.canFire(bulletsCount: state.bulletsCountRelay.value) else {
                    if state.weaponTypeRelay.value != .bazooka {
                        AudioUtil.playSound(of: .pistolOutBullets)
                    }
                    return
                }
                AudioUtil.playSound(of: state.weaponTypeRelay.value.firingSound)
                state.bulletsCountRelay.accept(
                    state.bulletsCountRelay.value - 1
                )
                
                sceneManager.fireWeapon()
                
                if state.weaponTypeRelay.value == .bazooka {
                    AudioUtil.playSound(of: .bazookaReload)
                    state.isBazookaReloading = true
                    // バズーカは自動リロード（3.2秒後に完了）
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                        state.bulletsCountRelay.accept(
                            state.weaponTypeRelay.value.bulletsCapacity
                        )
                        state.isBazookaReloading = false
                    }
                }
            }).disposed(by: disposeBag)
        
        motionDetector.reloadingMotionDetected
            .subscribe(onNext: { _ in
                guard self.canReload(bulletsCount: state.bulletsCountRelay.value,
                                     isBazookaReloading: state.isBazookaReloading) else { return }
                if state.weaponTypeRelay.value != .bazooka {
                    AudioUtil.playSound(of: .pistolReload)
                }
                state.bulletsCountRelay.accept(
                    state.weaponTypeRelay.value.bulletsCapacity
                )
            }).disposed(by: disposeBag)
        
        motionDetector.secretEventMotionDetected
            .subscribe(onNext: { _ in
                sceneManager.changeTargetsToTaimeisan()
                AudioUtil.playSound(of: .kyuiin)
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
        
        let sightImage = state.weaponTypeRelay
            .map({$0.sightImage})
        
        let sightImageColor = state.weaponTypeRelay
            .map({$0.sightImageColor})
        
        let timeCountText = state.timeCountRelay
            .map({TimeCountUtil.twoDigitTimeCount($0)})
        
        let bulletsCountImage = state.bulletsCountRelay
            .map({state.weaponTypeRelay.value.bulletsCountImage(at: $0)})
        
        input.weaponChangeButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showWeaponChangeView(
                    weaponSelectObserver: weaponSelectObserver
                )
            }).disposed(by: disposeBag)
        
        state.timeCountRelay
            .filter({$0 <= 0})
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                AudioUtil.playSound(of: .endWhistle)
                timerObservable?.dispose()
                motionDetector.stopUpdate()
                self.navigator.dismissWeaponChangeView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    AudioUtil.playSound(of: .rankingAppear)
                    self.navigator.showResultView(totalScore: state.score)
                })
            }).disposed(by: disposeBag)
        
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
    
    private func canReload(bulletsCount: Int, isBazookaReloading: Bool) -> Bool {
        return bulletsCount <= 0 && !isBazookaReloading
    }
}
