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
    let sightImageColor: Observable<UIColor>
    let bulletsCountImage: Observable<UIImage?>
    let timeCountString: Observable<String>
    let checkPlayerAnimation: Observable<Double>
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
        let _sightImage = BehaviorRelay<UIImage?>(value: GameConst.pistolSightImage)
        self.sightImage = _sightImage.asObservable()
        
        let _sightImageColor = BehaviorRelay<UIColor>(value: GameConst.pistolSightImageColor)
        self.sightImageColor = _sightImageColor.asObservable()
        
        let _bulletsCountImage = BehaviorRelay<UIImage?>(value: GameConst.pistolBulletsCountImage(GameConst.pistolBulletsCapacity))
        self.bulletsCountImage = _bulletsCountImage.asObservable()
        
        let _timeCountString = BehaviorRelay<String>(value: TimeCountUtil.twoDigitTimeCount(GameConst.timeCount))
        self.timeCountString = _timeCountString.asObservable()
        
        let _checkPlayerAnimation = BehaviorRelay<Double>(value: GameConst.timeCount)
        self.checkPlayerAnimation = _checkPlayerAnimation.asObservable()
        
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
                    CoreMotionUtil.stopUpdate()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        
                        AudioUtil.playSound(of: .rankingAppear)
                        _dismissSwitchWeaponVC.accept(Void())
                        _transitResultVC.accept(score)
                    })
                }
            }).disposed(by: disposeBag)
        
        let _ = stateManager.timeCount
            .subscribe(onNext: { element in
                //表示用に整えたStringを流す
                _timeCountString.accept(
                    TimeCountUtil.twoDigitTimeCount(element)
                )
                //0.2秒ごとにプレーヤーアニメーションを更新させる
                if (-(element - _checkPlayerAnimation.value) >= GameConst.playerAnimationUpdateInterval) {
                    _checkPlayerAnimation.accept(element)
                }
            }).disposed(by: disposeBag)
        
        let _ = stateManager.weaponSwitchingResult
            .withLatestFrom(stateManager.gameStatusChanged) { switchingResult, gameStatus in
                return (switchingResult, gameStatus)
            }
            .subscribe(onNext: { switchingResult, gameStatus in
                _showWeapon.accept(switchingResult.weapon)
                switch switchingResult.weapon {
                case .pistol:
                    _sightImage.accept(GameConst.pistolSightImage)
                    _sightImageColor.accept(GameConst.pistolSightImageColor)
                    _bulletsCountImage.accept(GameConst.pistolBulletsCountImage(switchingResult.bulletsCount))
                    //同じ武器が選択された時は鳴らさない
                    //プレイ中以外は鳴らさない（初回ロード時に鳴らすタイミングを制御するため）
                    if switchingResult.switched && gameStatus == .playing {
                        AudioUtil.playSound(of: .pistolSet)
                    }
                    
                case .bazooka:
                    _sightImage.accept(GameConst.bazookaSightImage)
                    _sightImageColor.accept(GameConst.bazookaSightImageColor)
                    _bulletsCountImage.accept(GameConst.bazookaBulletsCountImage(switchingResult.bulletsCount))
                    //同じ武器が選択された時は鳴らさない
                    if switchingResult.switched {
                        AudioUtil.playSound(of: .bazookaSet)
                    }
                }
            }).disposed(by: disposeBag)
        
        let _ = stateManager.weaponFiringResult
            .subscribe(onNext: { element in
                switch element.weapon {
                case .pistol:
                    switch element.result {
                    case .fired:
                        _fireWeapon.accept(Void())
                        AudioUtil.playSound(of: .pistolShoot)
                        _bulletsCountImage.accept(GameConst.pistolBulletsCountImage(element.remainingBulletsCount))
                        
                    case .canceled:
                        break
                        
                    case .noBullets:
                        AudioUtil.playSound(of: .pistolOutBullets)
                    }
                    
                case .bazooka:
                    if element.result == .fired {
                        _fireWeapon.accept(Void())
                        AudioUtil.playSound(of: .bazookaShoot)
                        AudioUtil.playSound(of: .bazookaReload)
                        _bulletsCountImage.accept(GameConst.bazookaBulletsCountImage(element.remainingBulletsCount))
                    }
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
                    _bulletsCountImage.accept(GameConst.pistolBulletsCountImage(GameConst.pistolBulletsCapacity))
                    
                case .bazooka:
                    _bulletsCountImage.accept(GameConst.bazookaBulletsCountImage(GameConst.bazookaBulletsCapacity))
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
            AudioUtil.playSound(of: .kyuiin)
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
