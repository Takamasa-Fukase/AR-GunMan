//
//  WeaponControlMotionDetector.swift
//  Sample_AR-GunMan_Replace
//
//  Created by ウルトラ深瀬 on 16/11/24.
//

import Foundation
import CoreMotion

public final class WeaponControlMotionDetector {
    public var fireMotionDetected: (() -> Void)?
    public var reloadMotionDetected: (() -> Void)?
    private let coreMotionManager: CMMotionManager
    
    public init() {
        coreMotionManager = CMMotionManager()
        setup()
    }
    
    // MARK: ユニットテスト時のみアクセスする
    #if DEBUG
    init(coreMotionManager: CMMotionManager) {
        self.coreMotionManager = coreMotionManager
        setup()
    }
    #endif

    public func startDetection() {
        guard let currentOperationQueue = OperationQueue.current else { return }
        startAccelerometerUpdates(operationQueue: currentOperationQueue)
        startGyroUpdates(operationQueue: currentOperationQueue)
    }
    
    public func stopDetection() {
        coreMotionManager.stopAccelerometerUpdates()
        coreMotionManager.stopGyroUpdates()
    }
    
    // MARK: Private Methods
    private func setup() {
        coreMotionManager.accelerometerUpdateInterval = 0.2
        coreMotionManager.gyroUpdateInterval = 0.2
    }
    
    private func startAccelerometerUpdates(operationQueue: OperationQueue) {
        guard !coreMotionManager.isAccelerometerActive else { return }
        
        coreMotionManager.startAccelerometerUpdates(to: operationQueue) { [weak self] data, error in
            if let error = error { print(error); return }
            guard let acceleration = data?.acceleration,
                  let latestGyro = self?.coreMotionManager.gyroData?.rotationRate else { return }
            
            DeviceMotionFilter.accelerationUpdated(
                acceleration: acceleration,
                latestGyro: latestGyro,
                onDetectFireMotion: {
                    self?.fireMotionDetected?()
                })
        }
    }
    
    private func startGyroUpdates(operationQueue: OperationQueue) {
        guard !coreMotionManager.isGyroActive else { return }
        
        coreMotionManager.startGyroUpdates(to: operationQueue) { [weak self] data, error in
            if let error = error { print(error); return }
            guard let gyro = data?.rotationRate else { return }
            
            DeviceMotionFilter.gyroUpdated(
                gyro: gyro,
                onDetectReloadMotion: {
                    self?.reloadMotionDetected?()
                })
        }
    }
}
