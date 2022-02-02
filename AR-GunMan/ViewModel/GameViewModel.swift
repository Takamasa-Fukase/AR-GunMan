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
    let rankingWillAppear: AnyObserver<Void>
    
    
    //output
    let showTutorial: Observable<Void>
    let startGame: Observable<Void>
    let fireWeapon: Observable<Void>
    let reloadPistol: Observable<Void>
    let changeTargetsToTaimeisan: Observable<Void>
    let dismissSwitchWeaponVC: Observable<Void>
    
    
    init() {
        
        //output
        let _showTutorial = PublishRelay<Void>()
        self.showTutorial = _showTutorial.asObservable()
        
        let _startGame = PublishRelay<Void>()
        self.startGame = _startGame.asObservable()
        
        let _fireWeapon = PublishRelay<Void>()
        self.fireWeapon = _fireWeapon.asObservable()
        
        let _reloadPistol = PublishRelay<Void>()
        self.reloadPistol = _reloadPistol.asObservable()
        
        let _changeTargetsToTaimeisan = PublishRelay<Void>()
        self.changeTargetsToTaimeisan = _changeTargetsToTaimeisan.asObservable()
        
        let _dismissSwitchWeaponVC = PublishRelay<Void>()
        self.dismissSwitchWeaponVC = _dismissSwitchWeaponVC.asObservable()
        
        //CoreMotionでイベントを検知した時にVCに通知
        CoreMotionModel.getAccelerometer {
            //各種武器の発動コード
            _fireWeapon.accept(Void())
        }
        CoreMotionModel.getGyro {
            //ピストルのリロードコード
            _reloadPistol.accept(Void())
            
        } secretEvent: {
            //泰明さんに変わるイベントの通知
            _changeTargetsToTaimeisan.accept(Void())
        }


        
        //input
        self.checkTutorialSeenStatus = AnyObserver<Void>() { _ in
            if UserDefaults.standard.value(forKey: UserDefaultsKey.tutorialAlreadySeen) == nil {
                print("tutorialAlreadySeen=false")
                _showTutorial.accept(Void())
                
            }else {
                print("tutorialAlreadySeen=true")
                _startGame.accept(Void())
            }
        }
        
        self.rankingWillAppear = AnyObserver<Void>() { _ in
            
            print("GameVM 武器選択を閉じる指示を流します")
                        
            _dismissSwitchWeaponVC.accept(Void())
        }
    }
    
    
}
