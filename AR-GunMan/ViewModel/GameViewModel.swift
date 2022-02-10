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
    
    //input
    let checkTutorialSeenStatus: AnyObserver<Void>
    let switchWeaponButtonTapped: AnyObserver<Void>
    let rankingWillAppear: AnyObserver<Void>
    
    
    //output
    let showTutorial: Observable<Void>
    let showSwitchWeaponVC: Observable<Void>
    let sightImage: Observable<UIImage?>
    let bulletsCountImage: Observable<UIImage?>
    
    let fireWeapon: Observable<Void>
    let reloadPistol: Observable<Void>
    let changeTargetsToTaimeisan: Observable<Void>
    let dismissSwitchWeaponVC: Observable<Void>
    
    //other
    private let disposeBag = DisposeBag()
    
    init() {
        let stateManager = GameStateManager()
        
        //output
        let _showTutorial = PublishRelay<Void>()
        self.showTutorial = _showTutorial.asObservable()
        
        let _showSwitchWeaponVC = PublishRelay<Void>()
        self.showSwitchWeaponVC = _showSwitchWeaponVC.asObservable()
        
        let _sightImage = BehaviorRelay<UIImage?>(value: Const.pistolSightImage)
        self.sightImage = _sightImage.asObservable()
        
        let _bulletsCountImage = BehaviorRelay<UIImage?>(value: Const.pistolBulletsCountImage(Const.pistolBulletsCapacity))
        self.bulletsCountImage = _bulletsCountImage.asObservable()
        
        
        let _fireWeapon = PublishRelay<Void>()
        self.fireWeapon = _fireWeapon.asObservable()
        
        let _reloadPistol = PublishRelay<Void>()
        self.reloadPistol = _reloadPistol.asObservable()
        
        let _changeTargetsToTaimeisan = PublishRelay<Void>()
        self.changeTargetsToTaimeisan = _changeTargetsToTaimeisan.asObservable()
        
        let _dismissSwitchWeaponVC = PublishRelay<Void>()
        self.dismissSwitchWeaponVC = _dismissSwitchWeaponVC.asObservable()
        
        //CoreMotionでイベントを検知した時にVCに通知
        CoreMotionUtil.getAccelerometer {
            //各種武器の発動コード
            _fireWeapon.accept(Void())
        }
        CoreMotionUtil.getGyro {
            //ピストルのリロードコード
            _reloadPistol.accept(Void())
            
        } secretEvent: {
            //泰明さんに変わるイベントの通知
            _changeTargetsToTaimeisan.accept(Void())
        }
                
        let _ = stateManager.gameStatusChanged
            .subscribe(onNext: { element in
                switch element {
                case .ready:
                    break

                case .start:
                    AudioUtil.playSound(of: .pistolSet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        AudioUtil.playSound(of: .startWhistle)
//                        stateManager.isShootEnabled.accept(true)
                    }
                    
                case .switchWeapon:
                    _sightImage.accept(nil)
                    _bulletsCountImage.accept(nil)
                    _showSwitchWeaponVC.accept(Void())

                case .pause:
                    break

                case .finish:
                    break
                }
            }).disposed(by: disposeBag)
        

        
        //input
        self.checkTutorialSeenStatus = AnyObserver<Void>() { _ in
            if UserDefaultsUtil.isTutorialAlreadySeen() {
                _showTutorial.accept(Void())
                
            }else {
                stateManager.startGame.onNext(Void())
            }
        }
        
        self.switchWeaponButtonTapped = AnyObserver<Void>() { _ in
            stateManager.prepareForSwitchWeapon.onNext(Void())
        }
        
        self.rankingWillAppear = AnyObserver<Void>() { _ in
            _dismissSwitchWeaponVC.accept(Void())
        }
    }
    
    
}
