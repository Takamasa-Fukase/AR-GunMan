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
    let tutorialEnded: AnyObserver<Void>
    let userShookDevide: AnyObserver<Void>
    let userRotateDevice: AnyObserver<Void>
    let userRotateDevice20Times: AnyObserver<Void>
    let weaponItemTapped: AnyObserver<Int>
    let targetHit: AnyObserver<Void>
    
    //MARK: - output
    let sightImage: Observable<UIImage?>
    let bulletsCountImage: Observable<UIImage?>
    let timeCountString: Observable<String>
    let showWeapon: Observable<WeaponTypes>
    let fireWeapon: Observable<Void>
    let excuteSecretEvent: Observable<Void>
    let dismissSwitchWeaponVC: Observable<Void>
    let transitResultVC: Observable<Double>
    
    //other
    private let disposeBag = DisposeBag()
    
    init() {
        let stateManager = GameStateManager()
        
        //MARK: - output
        let _sightImage = BehaviorRelay<UIImage?>(value: Const.pistolSightImage)
        self.sightImage = _sightImage.asObservable()
        
        let _bulletsCountImage = BehaviorRelay<UIImage?>(value: Const.pistolBulletsCountImage(Const.pistolBulletsCapacity))
        self.bulletsCountImage = _bulletsCountImage.asObservable()
        
        let _timeCountString = BehaviorRelay<String>(value: TimeCountUtil.twoDigitTimeCount(Const.timeCount))
        self.timeCountString = _timeCountString.asObservable()
        
        let _showWeapon = BehaviorRelay<WeaponTypes>(value: .pistol)
        self.showWeapon = _showWeapon.asObservable()
        
        let _fireWeapon = PublishRelay<Void>()
        self.fireWeapon = _fireWeapon.asObservable()
        
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
                case .pause:
                    _sightImage.accept(nil)
                    _bulletsCountImage.accept(nil)

                case .playing:
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
        
        let _ = stateManager.weaponSwitchingResult
            .subscribe(onNext: { element in
                _showWeapon.accept(element.weapon)
                switch element.weapon {
                case .pistol:
                    _sightImage.accept(Const.pistolSightImage)
                    _bulletsCountImage.accept(Const.pistolBulletsCountImage(element.bulletsCount))
                    //同じ武器が選択された時は鳴らさない
                    if element.switched {
                        AudioUtil.playSound(of: .pistolSet)
                    }
                    
                case .bazooka:
                    _sightImage.accept(Const.bazookaSightImage)
                    _bulletsCountImage.accept(Const.bazookaBulletsCountImage(element.bulletsCount))
                    //同じ武器が選択された時は鳴らさない
                    if element.switched {
                        AudioUtil.playSound(of: .bazookaSet)
                    }
                    
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        let _ = stateManager.weaponFiringResult
            .subscribe(onNext: { element in
                _fireWeapon.accept(Void())
                switch element.weapon {
                case .pistol:
                    switch element.result {
                    case .fired:
                        AudioUtil.playSound(of: .pistolShoot)
                        _bulletsCountImage.accept(Const.pistolBulletsCountImage(element.remainingBulletsCount))
                        
                    case .canceled:
                        break
                        
                    case .noBullets:
                        AudioUtil.playSound(of: .pistolOutBullets)
                    }
                    
                case .bazooka:
                    if element.result == .fired {
                        AudioUtil.playSound(of: .bazookaShoot)
                        AudioUtil.playSound(of: .bazookaReload)
                        _bulletsCountImage.accept(Const.bazookaBulletsCountImage(element.remainingBulletsCount))
                    }
                    
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        let _ = stateManager.weaponReloadingResult
            .subscribe(onNext: { element in
                if element.result != .completed {
                    return
                }
                switch element.weapon {
                case .pistol:
                    AudioUtil.playSound(of: .pistolReload)
                    _bulletsCountImage.accept(Const.pistolBulletsCountImage(Const.pistolBulletsCapacity))
                    
                case .bazooka:
                    _bulletsCountImage.accept(Const.bazookaBulletsCountImage(Const.bazookaBulletsCapacity))
                    
                default:
                    break
                }
            }).disposed(by: disposeBag)

        
        //MARK: - input
        self.tutorialEnded = AnyObserver<Void>() { _ in
            stateManager.startGame.onNext(Void())
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
        
        self.weaponItemTapped = AnyObserver<Int>() { event in
            guard let index = event.element else {return}
            stateManager.requestSwitchingWeapon.onNext(WeaponTypes.allCases[index])
        }
        
        self.targetHit = AnyObserver<Void>() { _ in
            stateManager.addScore.onNext(Void())
        }
    }
    
    
}
