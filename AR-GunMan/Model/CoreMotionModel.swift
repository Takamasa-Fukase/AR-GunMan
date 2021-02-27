//
//  CoreMotionModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2021/02/27.
//

import Foundation
import CoreMotion

class CoreMotionModel {
    
    //coreMotion
    private static var preBool = false
    private static var postBool = false
    
    private static var accele = CMAcceleration()
    private static var gyro = CMRotationRate()
    private static let motionManager = CMMotionManager()
    
    private static var gyroZcount = 0
    
    
    //加速度設定
    static func getAccelerometer(action: (() -> ())?) {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data, error) in
            
            DispatchQueue.main.async {
                guard let acceleration = data?.acceleration else { return }
                self.accele = acceleration
                self.didUpdateAccelerationData(data: acceleration) {
                    action?()
                }
            }
        }
    }
    //ジャイロ設定
    static func getGyro(action: (() -> ())?, secretEvent: (() -> ())?) {
        motionManager.gyroUpdateInterval = 0.2
        motionManager.startGyroUpdates(to: OperationQueue.current!) {
            (data, error) in
            
            DispatchQueue.main.async {
                guard let rotationRate = data?.rotationRate else { return }
                self.gyro = rotationRate
                self.didUpdateGyroData(data: rotationRate, completion: {
                    action?()
                }) {
                    secretEvent?()
                }
            }
        }
    }
    
    static func didUpdateAccelerationData(data: CMAcceleration, completion: (() -> ())?) {
        let compositAcceleration = CalcuModel.getCompositeAcceleration(0, data.y, data.z)
        
        let gyroZ = (gyro.z * gyro.z)
        
        //連続動作の内の初回
        if !postBool
            && compositAcceleration >= 1.5
            && gyroZ < 10 {
            
            preBool = true
            
            //武器を発動
            completion?()
        }
        
        //連続動作の内の2回目以降
        if postBool
            && compositAcceleration >= 1.5
            && gyroZ < 10 {
            
            postBool = false
            preBool = false
            
            //武器を発動
            completion?()
        }
    }
    
    static func didUpdateGyroData(data: CMRotationRate, completion: (() -> ())?, secretEvent: (() -> ())?) {
        let compositGyro = CalcuModel.getCompositeGyro(0, 0, gyro.z)

        if compositGyro >= 10 {
            
            completion?()
            
            gyroZcount += 1
            print("gyroZcountを+1。 現在: \(gyroZcount)回")
            
        }
        
        if gyroZcount == 20 {
            
            print("gyroZcountが20に達したのでターゲットを泰明さんに変えます")
            
            secretEvent?()
        }

    }
}
