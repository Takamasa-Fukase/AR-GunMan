//
//  CoreMotionRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/03/25.
//

import CoreMotion
import RxSwift
import RxCocoa

final class CoreMotionRepository {
    private let coreMotionManager: CMMotionManager
    private let accelerationRelay = PublishRelay<CMAcceleration>()
    private let rotationRateRelay = PublishRelay<CMRotationRate>()
    
    init(coreMotionManager: CMMotionManager) {
        self.coreMotionManager = coreMotionManager
    }

    func startUpdate() {
        if !coreMotionManager.isAccelerometerActive {
            coreMotionManager.accelerometerUpdateInterval = 0.2
            coreMotionManager.startAccelerometerUpdates(to: OperationQueue.current!) {
                (data, _) in
                self.accelerationRelay.accept(
                    data?.acceleration ?? CMAcceleration(x: 0, y: 0, z: 0)
                )
            }
        }
        if !coreMotionManager.isGyroActive {
            coreMotionManager.gyroUpdateInterval = 0.2
            coreMotionManager.startGyroUpdates(to: OperationQueue.current!) {
                (data, _) in
                self.rotationRateRelay.accept(
                    data?.rotationRate ?? CMRotationRate(x: 0, y: 0, z: 0)
                )
            }
        }
    }
    
    func stopUpdate() {
        coreMotionManager.stopAccelerometerUpdates()
        coreMotionManager.stopGyroUpdates()
    }
    
    func getAccelerationStream() -> Observable<CMAcceleration> {
        return accelerationRelay.asObservable()
    }
    
    func getGyroStream() -> Observable<CMRotationRate> {
        return rotationRateRelay.asObservable()
    }
}
