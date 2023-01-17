//
//  MotionDetector.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 14/1/23.
//

import CoreMotion
import RxSwift
import RxCocoa

class MotionDetector {
    let firingMotionDetected: Observable<Void>
    let reloadingMotionDetected: Observable<Void>
    let secretEventMotionDetected: Observable<Void>
    
    private var preBool = false
    private var postBool = false
    private var accele = CMAcceleration()
    private var gyro = CMRotationRate()
    private let motionManager = CMMotionManager()
    private var gyroZcount = 0
    
    init() {
        let firingMotionDetectedRelay = PublishRelay<Void>()
        let reloadingMotionDetectedRelay = PublishRelay<Void>()
        let secretEventMotionDetectedRelay = PublishRelay<Void>()
        
        self.firingMotionDetected = firingMotionDetectedRelay.asObservable()
        self.reloadingMotionDetected = reloadingMotionDetectedRelay.asObservable()
        self.secretEventMotionDetected = secretEventMotionDetectedRelay.asObservable()
        
        self.motionManager.accelerometerUpdateInterval = 0.2
        self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data, error) in
            DispatchQueue.main.async {
                guard let acceleration = data?.acceleration else { return }
                self.accele = acceleration
                self.didUpdateAccelerationData(data: acceleration) {
                    firingMotionDetectedRelay.accept(Void())
                }
            }
        }
        
        self.motionManager.gyroUpdateInterval = 0.2
        self.motionManager.startGyroUpdates(to: OperationQueue.current!) {
            (data, error) in
            DispatchQueue.main.async {
                guard let rotationRate = data?.rotationRate else { return }
                self.gyro = rotationRate
                self.didUpdateGyroData(data: rotationRate, completion: {
                    reloadingMotionDetectedRelay.accept(Void())
                }) {
                    secretEventMotionDetectedRelay.accept(Void())
                }
            }
        }
    }

    func stopUpdate() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    
    //MARK: - Private Methods
    private func didUpdateAccelerationData(data: CMAcceleration, completion: (() -> ())?) {
        let compositAcceleration = getCompositeAcceleration(0, data.y, data.z)
        
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
    
    private func didUpdateGyroData(data: CMRotationRate, completion: (() -> ())?, secretEvent: (() -> ())?) {
        let compositGyro = getCompositeGyro(0, 0, gyro.z)

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
        
    private func getCompositeAcceleration(_ x: Double, _ y: Double, _ z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
    
    private func getCompositeGyro(_ x: Double, _ y: Double, _ z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
