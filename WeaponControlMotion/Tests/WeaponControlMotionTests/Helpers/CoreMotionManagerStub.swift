//
//  CoreMotionManagerStub.swift
//  WeaponControlMotionTests
//
//  Created by ウルトラ深瀬 on 20/12/24.
//

import Foundation
import CoreMotion

final class CoreMotionManagerStub: CMMotionManager {
    var startAccelerometerUpdatesCalledCount = 0
    var startGyroUpdatesCalledCount = 0
    var stopAccelerometerUpdatesCalledCount = 0
    var stopGyroUpdatesCalledCount = 0
    var accelerometerHander: CMAccelerometerHandler?
    var gyroHander: CMGyroHandler?
    var latestAccelerometerData: CMAccelerometerData? = nil
    var latestGyroData: CMGyroData? = nil

    override var accelerometerData: CMAccelerometerData? {
        return latestAccelerometerData
    }
    override var gyroData: CMGyroData? {
        return latestGyroData
    }
    
    override func startAccelerometerUpdates(to queue: OperationQueue, withHandler handler: @escaping CMAccelerometerHandler) {
        accelerometerHander = { [weak self] (data, error) in
            self?.latestAccelerometerData = data
            handler(data, error)
        }
        startAccelerometerUpdatesCalledCount += 1
    }
    
    override func startGyroUpdates(to queue: OperationQueue, withHandler handler: @escaping CMGyroHandler) {
        gyroHander = { [weak self] (data, error) in
            self?.latestGyroData = data
            handler(data, error)
        }
        startGyroUpdatesCalledCount += 1
    }
    
    override func stopAccelerometerUpdates() {
        stopAccelerometerUpdatesCalledCount += 1
    }
    
    override func stopGyroUpdates() {
        stopGyroUpdatesCalledCount += 1
    }
}
