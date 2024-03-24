//
//  GameViewModel2.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/03/23.
//

import RxSwift
import RxCocoa
import ARKit

class GameViewModel2 {
    struct Input {
        let viewDidAppear: Observable<Void>
        let tutorialEnded: Observable<Void>
        let weaponChangeButtonTapped: Observable<Void>
        let weaponSelected: Observable<WeaponType>
    }
    
    struct Output {
        let showTutorialView: Observable<Void>
        let sightImage: Observable<UIImage?>
        let sightImageColor: Observable<UIColor>
        let timeCountText: Observable<String>
        let bulletsCountImage: Observable<UIImage?>
        let showWeaponChangeView: Observable<Void>
        let dismissWeaponChangeView: Observable<Void>
        let showResultView: Observable<Double>
    }
    
    struct State {
        let weaponTypeRelay = BehaviorRelay<WeaponType>(value: .pistol)
        let bulletsCountRelay = BehaviorRelay<Int>(value: WeaponType.pistol.bulletsCapacity)
        var isBazookaReloading: Bool = false
        let timeCountRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
        var score: Double = 0
    }
    
    private let tutorialRepository: TutorialRepository
    private let disposeBag = DisposeBag()
    
    init(tutorialRepository: TutorialRepository) {
        self.tutorialRepository = tutorialRepository
    }
    
    func transform(
        input: Input,
        sceneManager: GameSceneManager
    ) -> Output {
        var state = State()
        let motionDetector = MotionDetector()
        var timerObservable: Disposable?
        let dismissWeaponChangeViewRelay = PublishRelay<Void>()
        let showResultViewRelay = PublishRelay<Double>()
        let showTutorialViewRelay = PublishRelay<Void>()
        
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
        
        input.weaponSelected
            .subscribe(onNext: { weaponType in
                state.weaponTypeRelay.accept(weaponType)
                dismissWeaponChangeViewRelay.accept(Void())
                AudioUtil.playSound(of: weaponType.weaponChangingSound)
                state.bulletsCountRelay.accept(
                    weaponType.bulletsCapacity
                )
                state.isBazookaReloading = false
            }).disposed(by: disposeBag)
        
        input.tutorialEnded
            .subscribe(onNext: { _ in
                startGame()
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

        input.viewDidAppear
            .take(1)
            .flatMapLatest { [unowned self] _ in
                return self.tutorialRepository.getIsTutorialSeen()
            }
            .subscribe(onNext: { isSeen in
                if isSeen {
                    startGame()
                }else {
                    showTutorialViewRelay.accept(Void())
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
        
        let showWeaponChangeView = input.weaponChangeButtonTapped
        
        state.timeCountRelay
            .filter({$0 <= 0})
            .subscribe(onNext: { _ in
                AudioUtil.playSound(of: .endWhistle)
                timerObservable?.dispose()
                motionDetector.stopUpdate()
                dismissWeaponChangeViewRelay.accept(Void())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    AudioUtil.playSound(of: .rankingAppear)
                    showResultViewRelay.accept(state.score)
                })
            }).disposed(by: disposeBag)
        
        return Output(
            showTutorialView: showTutorialViewRelay.asObservable(),
            sightImage: sightImage,
            sightImageColor: sightImageColor,
            timeCountText: timeCountText,
            bulletsCountImage: bulletsCountImage,
            showWeaponChangeView: showWeaponChangeView,
            dismissWeaponChangeView: dismissWeaponChangeViewRelay.asObservable(),
            showResultView: showResultViewRelay.asObservable()
        )
    }
    
    private func canFire(bulletsCount: Int) -> Bool {
        return bulletsCount > 0
    }
    
    private func canReload(bulletsCount: Int, isBazookaReloading: Bool) -> Bool {
        return bulletsCount <= 0 && !isBazookaReloading
    }
}
