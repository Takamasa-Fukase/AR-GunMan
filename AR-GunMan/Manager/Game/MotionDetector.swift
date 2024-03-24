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

    private let motionManager = CMMotionManager()
    private var gyroZcount = 0
    // 発射動作の判定では加速度＋ジャイロも使うので、最新の値としてここに格納して使う
    private var gyroCompositeValue: Double = 0.0
    
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
            guard let acceleration = data?.acceleration else { return }
            let accelerationCompositeValue = self.getCompositeValue(
                x: 0,
                y: acceleration.y,
                z: acceleration.z
            )
            DispatchQueue.main.async {
                self.handleUpdatedAccelerationData(
                    compositeValue: accelerationCompositeValue,
                    gyroZSquaredValue: self.gyroCompositeValue,
                    completion: {
                        firingMotionDetectedRelay.accept(Void())
                    }
                )
            }
        }
        
        self.motionManager.gyroUpdateInterval = 0.2
        self.motionManager.startGyroUpdates(to: OperationQueue.current!) {
            (data, error) in
            guard let rotationRate = data?.rotationRate else { return }
            // 加速度の方の判定でジャイロも使うので格納する
            self.gyroCompositeValue = self.getCompositeValue(
                x: 0,
                y: 0,
                z: rotationRate.z
            )
            DispatchQueue.main.async {
                self.handleUpdatedGyroData(
                    compositeValue: self.gyroCompositeValue,
                    completion: {
                        reloadingMotionDetectedRelay.accept(Void())
                    }, secretEvent: {
                        secretEventMotionDetectedRelay.accept(Void())
                    }
                )
            }
        }
    }

    func stopUpdate() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    
    //MARK: - Private Methods
    private func handleUpdatedAccelerationData(
        compositeValue: Double,
        gyroZSquaredValue: Double,
        completion: () -> Void
    ) {
        if compositeValue >= 1.5 && gyroZSquaredValue < 10 {
            completion()
        }
    }
    
    private func handleUpdatedGyroData(
        compositeValue: Double,
        completion: () -> Void,
        secretEvent: () -> Void
    ) {
        if compositeValue >= 10 {
            completion()
            gyroZcount += 1
        }
        if gyroZcount == 20 {
            secretEvent()
        }
    }
    
    private func getCompositeValue(x: Double, y: Double, z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
