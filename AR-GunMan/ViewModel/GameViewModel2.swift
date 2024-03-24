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
        let weaponChangeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let showTutorialView: Observable<TutorialDelegate>
        let sightImage: Observable<UIImage?>
        let sightImageColor: Observable<UIColor>
        let timeCountText: Observable<String>
        let bulletsCountImage: Observable<UIImage?>
        let showWeaponChangeView: Observable<WeaponChangeDelegate>
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
    
    private let weaponSelectedRelay = PublishRelay<WeaponType>()
    
    func transform(
        input: Input,
        sceneManager: GameSceneManager,
        disposeBag: DisposeBag
    ) -> Output {
        var state = State()
        let dismissWeaponChangeViewRelay = PublishRelay<Void>()
        let showResultViewRelay = PublishRelay<Double>()
        
        // middle
        weaponSelectedRelay
            .subscribe(onNext: { weaponType in
                state.weaponTypeRelay.accept(weaponType)
                dismissWeaponChangeViewRelay.accept(Void())
            }).disposed(by: disposeBag)
        
        let motionDetector = MotionDetector()
        
        state.weaponTypeRelay
            .subscribe(onNext: { weaponType in
                AudioUtil.playSound(of: weaponType.weaponChangingSound)
                state.bulletsCountRelay.accept(
                    weaponType.bulletsCapacity
                )
                state.isBazookaReloading = false
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
        
        // middle -> output
        var timerObservable: Disposable?
        let tutorialSeenChecker = TutorialSeenChecker2()
        let showTutorialViewRelay = PublishRelay<TutorialDelegate>()
        
        tutorialSeenChecker.checkTutorialSeen()
            .subscribe(onNext: { isSeen in
                if isSeen {
                    AudioUtil.playSound(of: .pistolSet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        AudioUtil.playSound(of: .startWhistle)
                        timerObservable = TimeCountUtil.createRxTimer(.milliseconds(10))
                            .map({ _ in
                                TimeCountUtil.decreaseGameTimeCount(lastValue: state.timeCountRelay.value)
                            })
                            .bind(to: state.timeCountRelay)
                    }
                }else {
                    showTutorialViewRelay.accept(tutorialSeenChecker)
                }
            }).disposed(by: disposeBag)
        
        
        // output
        let sightImage = state.weaponTypeRelay
            .map({$0.sightImage})
        
        let sightImageColor = state.weaponTypeRelay
            .map({$0.sightImageColor})
        
        let timeCountText = state.timeCountRelay
            .map({TimeCountUtil.twoDigitTimeCount($0)})
        
        let bulletsCountImage = state.bulletsCountRelay
            .map({state.weaponTypeRelay.value.bulletsCountImage(at: $0)})
        
        let showWeaponChangeView: Observable<WeaponChangeDelegate> = input.weaponChangeButtonTapped
            .map({_ in self})
        
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

extension GameViewModel2: WeaponChangeDelegate {
    func weaponSelected(_ weaponType: WeaponType) {
        weaponSelectedRelay.accept(weaponType)
    }
}

