//
//  DeviceMotionController2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 23/6/24.
//

import CoreMotion
import RxSwift
import RxCocoa

final class DeviceMotionController2 {
    private let coreMotionManager: CMMotionManager
    private let accelerationUpdatedRelay = PublishRelay<CMAcceleration>()
    private let gyroUpdatedRelay = PublishRelay<CMRotationRate>()
    
    var accelerationUpdated: Observable<Vector> {
        return accelerationUpdatedRelay
            .asObservable()
            .map { acceleration in
                return Vector(x: acceleration.x, y: acceleration.y, z: acceleration.z)
            }
    }
    var gyroUpdated: Observable<Vector> {
        return gyroUpdatedRelay
            .asObservable()
            .map { gyro in
                return Vector(x: gyro.x, y: gyro.y, z: gyro.z)
            }
    }
    
    init(coreMotionManager: CMMotionManager) {
        self.coreMotionManager = coreMotionManager
    }
    
    func startUpdate() {
        if !coreMotionManager.isAccelerometerActive {
            coreMotionManager.accelerometerUpdateInterval = 0.2
            coreMotionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, _) in
                guard let acceleration = data?.acceleration else { return }
                self.accelerationUpdatedRelay.accept(acceleration)
            }
        }
        if !coreMotionManager.isGyroActive {
            coreMotionManager.gyroUpdateInterval = 0.2
            coreMotionManager.startGyroUpdates(to: OperationQueue.current!) { (data, _) in
                guard let rotationRate = data?.rotationRate else { return }
                self.gyroUpdatedRelay.accept(rotationRate)
            }
        }
    }
    
    func stopUpdate() {
        coreMotionManager.stopAccelerometerUpdates()
        coreMotionManager.stopGyroUpdates()
    }
}
