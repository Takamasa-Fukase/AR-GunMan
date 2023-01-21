//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/1/23.
//

import RxSwift
import RxCocoa

class GameViewModel {
    let showTutorialView: Observable<TutorialVCDelegate>
    let sightImage: Observable<UIImage?>
    let sightImageColor: Observable<UIColor>
    let timeCountText: Observable<String>
    let bulletsCountImage: Observable<UIImage?>
    let weaponTypeChanged: Observable<WeaponType>
    let weaponFired: Observable<Void>
    let showSwitchWeaponView: Observable<Void>
    let showResultView: Observable<Double>
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let targetHit: Observable<Void>
        let switchWeaponButtonTapped: Observable<Void>
    }
    
    struct Dependency {
        let tutorialSeenChecker: TutorialSeenChecker
        let motionDetector: MotionDetector
        let currentWeapon: CurrentWeapon
        let timeCounter: TimeCounter
        let scoreCounter: ScoreCounter
    }
    
    init(input: Input,
         dependency: Dependency) {

        input.viewDidAppear
            .take(1)
            .subscribe(onNext: { _ in
                dependency.tutorialSeenChecker.checkTutorialSeen()
            }).disposed(by: disposeBag)
        
        let showTutorialViewRelay = PublishRelay<TutorialVCDelegate>()
        self.showTutorialView = showTutorialViewRelay.asObservable()
            
        dependency.tutorialSeenChecker.isSeen
            .subscribe(onNext: { element in
                if element {
                    AudioUtil.playSound(of: .pistolSet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        AudioUtil.playSound(of: .startWhistle)
                        dependency.timeCounter.startTimer()
                    }
                }else {
                    showTutorialViewRelay.accept(dependency.tutorialSeenChecker)
                }
            }).disposed(by: disposeBag)
        
        self.sightImage = dependency.currentWeapon.weaponTypeChanged
            .map({$0.sightImage})
        
        self.sightImageColor = dependency.currentWeapon.weaponTypeChanged
            .map({$0.sightImageColor})
        
        self.timeCountText = dependency.timeCounter.countChanged
            .map({TimeCountUtil.twoDigitTimeCount($0)})
        
        self.bulletsCountImage = dependency.currentWeapon.bulletsCountChanged
            .map({dependency.currentWeapon.weaponType.bulletsCountImage(at: $0)})
        
        self.weaponTypeChanged = dependency.currentWeapon.weaponTypeChanged
        
        self.weaponFired = dependency.currentWeapon.fired
        
        self.showSwitchWeaponView = input.switchWeaponButtonTapped
        
        let showResultViewRelay = PublishRelay<Double>()
        self.showResultView = showResultViewRelay.asObservable()
        
        dependency.timeCounter.countChanged
            .filter({$0 <= 0})
            .subscribe(onNext: { _ in
                AudioUtil.playSound(of: .endWhistle)
                dependency.timeCounter.disposeTimer()
                dependency.motionDetector.stopUpdate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    showResultViewRelay.accept(dependency.scoreCounter.totalScore)
                })
            }).disposed(by: disposeBag)
        
        dependency.motionDetector.firingMotionDetected
            .subscribe(onNext: { _ in
                dependency.currentWeapon.fire()
            }).disposed(by: disposeBag)
        
        dependency.motionDetector.reloadingMotionDetected
            .subscribe(onNext: { _ in
                dependency.currentWeapon.reload()
            }).disposed(by: disposeBag)
        
        dependency.motionDetector.secretEventMotionDetected
            .subscribe(onNext: { _ in
                
            }).disposed(by: disposeBag)
                
        input.targetHit
            .subscribe(onNext: { _ in
                AudioUtil.playSound(of: dependency.currentWeapon.weaponType.hitSound)
                dependency.scoreCounter.addScore(weaponType: dependency.currentWeapon.weaponType)
            }).disposed(by: disposeBag)
    }
}
