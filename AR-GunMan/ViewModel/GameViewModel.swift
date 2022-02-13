//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/22.
//

import Foundation
import RxSwift
import RxCocoa

class GameViewModel {
    
    //MARK: - input
    let checkTutorialSeenStatus: AnyObserver<Void>
    let userShookDevide: AnyObserver<Void>
    let userRotateDevice: AnyObserver<Void>
    let userRotateDevice20Times: AnyObserver<Void>
    let switchWeaponButtonTapped: AnyObserver<Void>
    let weaponItemTapped: AnyObserver<Int>
    
    
    //MARK: - output
    let showTutorial: Observable<Void>
    let showSwitchWeaponVC: Observable<Void>
    let sightImage: Observable<UIImage?>
    let bulletsCountImage: Observable<UIImage?>
    let timeCountString: Observable<String>
    let excuteSecretEvent: Observable<Void>
    let dismissSwitchWeaponVC: Observable<Void>
    let transitResultVC: Observable<Double>
    
    //other
    private let disposeBag = DisposeBag()
    
    init() {
        let stateManager = GameStateManager()
        
        //MARK: - output
        let _showTutorial = PublishRelay<Void>()
        self.showTutorial = _showTutorial.asObservable()
        
        let _showSwitchWeaponVC = PublishRelay<Void>()
        self.showSwitchWeaponVC = _showSwitchWeaponVC.asObservable()
        
        let _sightImage = BehaviorRelay<UIImage?>(value: Const.pistolSightImage)
        self.sightImage = _sightImage.asObservable()
        
        let _bulletsCountImage = BehaviorRelay<UIImage?>(value: Const.pistolBulletsCountImage(Const.pistolBulletsCapacity))
        self.bulletsCountImage = _bulletsCountImage.asObservable()
        
        let _timeCountString = BehaviorRelay<String>(value: TimeCountUtil.twoDigitTimeCount(Const.timeCount))
        self.timeCountString = _timeCountString.asObservable()
        
        let _excuteSecretEvent = PublishRelay<Void>()
        self.excuteSecretEvent = _excuteSecretEvent.asObservable()
        
        let _transitResultVC = PublishRelay<Double>()
        self.transitResultVC = _transitResultVC.asObservable()
        
        let _dismissSwitchWeaponVC = PublishRelay<Void>()
        self.dismissSwitchWeaponVC = _dismissSwitchWeaponVC.asObservable()
                
        
        //MARK: - stateManagerの変更を購読してVCに指示を流す
        let _ = stateManager.gameStatusChanged
            .withLatestFrom(stateManager.totalScore) { status, score in
                return (status, score)
            }
            .subscribe(onNext: { status, score in
                switch status {
                case .ready:
                    break

                case .start:
                    AudioUtil.playSound(of: .pistolSet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        AudioUtil.playSound(of: .startWhistle)
                    }
                    
                case .switchWeapon:
                    _sightImage.accept(nil)
                    _bulletsCountImage.accept(nil)
                    _showSwitchWeaponVC.accept(Void())

                case .pause:
                    break

                case .finish:
                    AudioUtil.playSound(of: .endWhistle)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        
                        AudioUtil.playSound(of: .rankingAppear)
                        _dismissSwitchWeaponVC.accept(Void())
                        _transitResultVC.accept(score)
                    })
                }
            }).disposed(by: disposeBag)
        
        let _ = stateManager.timeCount
            .map({ TimeCountUtil.twoDigitTimeCount($0) })
            .bind(to: _timeCountString)
            .disposed(by: disposeBag)
        
        let _ = stateManager.weaponSelected
            .subscribe(onNext: { element in
                switch element {
                case .pistol:
                    break
                case .bazooka:
                    break
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        let _ = stateManager.weaponFirableReaction
            .subscribe(onNext: { element in
                switch element {
                case .fireAvailable:
                    break
                case .fireUnavailable:
                    break
                case .noBullets:
                    break
                }
            }).disposed(by: disposeBag)
        
        let _ = stateManager.isReloadWeaponEnabled
            .subscribe(onNext: { element in
                
            }).disposed(by: disposeBag)

        
        //MARK: - input
        self.checkTutorialSeenStatus = AnyObserver<Void>() { _ in
            if UserDefaultsUtil.isTutorialAlreadySeen() {
                _showTutorial.accept(Void())
                
            }else {
                stateManager.startGame.onNext(Void())
            }
        }
        
        self.userShookDevide = AnyObserver<Void>() { _ in
            stateManager.requestFiringWeapon.onNext(Void())
        }
        
        self.userRotateDevice = AnyObserver<Void>() { _ in
            stateManager.requestReloadingWeapon.onNext(Void())
        }
        
        self.userRotateDevice20Times = AnyObserver<Void>() { _ in
            _excuteSecretEvent.accept(Void())
        }
        
        self.switchWeaponButtonTapped = AnyObserver<Void>() { _ in
            stateManager.requestShowingSwitchWeaponPage.onNext(Void())
        }
        
        self.weaponItemTapped = AnyObserver<Int>() { event in
            guard let index = event.element else {return}
            stateManager.requestSwitchingWeapon.onNext(
                WeaponTypes.allCases[index]
            )
        }
    }
    
    
}
