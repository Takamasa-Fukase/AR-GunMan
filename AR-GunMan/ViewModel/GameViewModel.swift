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
    
    //count
    let targetCount = 50
    let pistolBulletsCount: Observable<Int> // = 7
    let bazookaRocketCount: Observable<Int> // = 1
    let explosionCount: Observable<Int> // = 0
    
//    let timer:Timer!
    let timeCount: Observable<Double> // = 30.00
    
    //score
    let pistolPoint = 0.0
    let bazookaPoint = 0.0
    
    //nodeAnimation
    let toggleActionInterval = 0.2
    let lastCameraPos: (Float, Float, Float) = (0, 0, 0)
    let isPlayerRunning = false
    let lastPlayerStatus = false
    
    
    init() {
        
        let gameManager = GameManager()
        
        var timer: Timer?
        
        //count
        let targetCount: Observable<Int> // = 50
        let pistolBulletsCount: Observable<Int> // = 7
        let bazookaRocketCount: Observable<Int> // = 1
        let explosionCount: Observable<Int> // = 0
        
        let timeCount: Double = 30.00
        
        //score
        let pistolPoint = 0.0
        let bazookaPoint = 0.0
        
        //nodeAnimation
        let toggleActionInterval = 0.2
        let lastCameraPos: (Float, Float, Float) = (0, 0, 0)
        let isPlayerRunning = false
        let lastPlayerStatus = false
        
        var currentWeapon: WeaponTypes = .pistol
        
        var isShootEnabled = false
        
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


        
        //input
        self.checkTutorialSeenStatus = AnyObserver<Void>() { _ in
            if UserDefaults.standard.value(forKey: UserDefaultsKey.tutorialAlreadySeen) == nil {
                print("tutorialAlreadySeen=false")
                _showTutorial.accept(Void())
                
            }else {
                print("tutorialAlreadySeen=true")
                _startGame.accept(Void())
                
                AudioUtil.playSound(of: .pistolSet)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    AudioUtil.playSound(of: .startWhistle)
                    isShootEnabled = true
//                    timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.timerUpdate(timer:)), userInfo: nil, repeats: true)
                    timer = TimerUtil.startTimer()
                }
            }
        }
        
        self.rankingWillAppear = AnyObserver<Void>() { _ in
            
            print("GameVM 武器選択を閉じる指示を流します")
                        
            _dismissSwitchWeaponVC.accept(Void())
        }
    }
    
    
}
