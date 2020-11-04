//
//  GamePresenter.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/08/16.
//  Copyright © 2020 fukase. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

enum SoundType: Int {
    case pistol = 0
    case target = 1
}
 
protocol GameInterface: AnyObject {
    func addPistol()
    func addBullet()
    func shootBullet()
    func addTarget()
    func setSounds(for soundType: SoundType?)
    func playSound(of index: Int)
    func vibration()
    func setBulletsImageView(with image: UIImage?)
}

class GamePresenter {
    
    private var preBool = false
    private var postBool = false
    
    private var pistolBulletsCount = 7
    var accele = CMAcceleration()
    var gyro = CMRotationRate()
    
    var isShootEnabled = false
    
    private weak var listener: GameInterface!
    
    private var model = CalcuModel()
    
    init(listener: GameInterface) {
        self.listener = listener
    }
    
    func viewDidLoad() {
        listener.addPistol()
        listener.addTarget()
        guard let soundType = SoundType(rawValue: 0) else {return}
        listener.setSounds(for: soundType)
        listener.playSound(of: 1)
        listener.setBulletsImageView(with: UIImage(named: "bullets\(pistolBulletsCount)"))
    }
    
    func didUpdateAccelerationData(data: CMAcceleration) {
        pistolAccelerometer(data.x, data.y, data.z)
    }
    
    func didUpdateGyroData(data: CMRotationRate) {
        pistolGyro(data.x, data.y, data.z)
    }
}

extension GamePresenter {
    
    func pistolAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        
//        if isShootEnabled {
            let compositAcceleration = model.getCompositeAcceleration(0, y, z)
    //        let compositGyro = model.getCompositeGyro(gyro.x, gyro.y, gyro.z)
    //        let gyroX = (gyro.x * gyro.x)
    //        let gyroY = (gyro.y * gyro.y)
            let gyroZ = (gyro.z * gyro.z)
    //        if gyroX >= 1.5 {
    //            print("gyroXが1.5以上です(\(gyroX)")
    //        }
    //        if gyroY >= 3 {
    //            print("gyroYが3以上です(\(gyroY)")
    //        }
    //        if gyroZ >= 10 {
    //            print("gyroZが1.5以上です(\(gyroZ)")
    //        }
            if !postBool
                && compositAcceleration >= 1.5
    //            && gyroX < 1.5
    //            && gyroY < 3
                && gyroZ < 10 {
                if pistolBulletsCount > 0 {
                    pistolBulletsCount -= 1
                    
                    listener.addBullet()
                    listener.shootBullet()
                    
                    listener.playSound(of: 2)
                    listener.vibration()
                    preBool = true
                }else if pistolBulletsCount <= 0 {
                    listener.playSound(of: 3)
                    preBool = true
                }
                print("ピストルの残弾数: \(pistolBulletsCount) / 7発")
            }
            if postBool
                && compositAcceleration >= 1.5
                //            && gyroX < 1.5
                //            && gyroY < 3
                && gyroZ < 10 {
                if pistolBulletsCount > 0 {
                    pistolBulletsCount -= 1
                    
                    listener.addBullet()
                    listener.shootBullet()
                    
                    listener.playSound(of: 2)
                    listener.vibration()
                    postBool = false
                    preBool = false
                }else if pistolBulletsCount <= 0 {
                    listener.playSound(of: 3)
                    postBool = false
                    preBool = false
                }
                print("ピストルの残弾数: \(pistolBulletsCount) / 7発")
            }
            listener.setBulletsImageView(with: UIImage(named: "bullets\(pistolBulletsCount)"))
//        }
        
    }
    
    func pistolGyro(_ x: Double, _ y: Double, _ z: Double) {
        
//        if isShootEnabled {
            
            let compositGyro = model.getCompositeGyro(0, 0, gyro.z)
            
            if pistolBulletsCount <= 0 && compositGyro >= 10 {
                print("リロード時gyroZ: \(compositGyro)")
                
                pistolBulletsCount = 7
                listener.playSound(of: 4)
                print("ピストルの弾をリロードしました  残弾数: \(pistolBulletsCount)発")
            }
            listener.setBulletsImageView(with: UIImage(named: "bullets\(pistolBulletsCount)"))
            
//        }
        
    }
    
}
