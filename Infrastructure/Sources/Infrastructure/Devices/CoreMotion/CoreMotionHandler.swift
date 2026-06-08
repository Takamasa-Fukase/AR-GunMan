//
//  CoreMotionHandler.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/06/05.
//

import Foundation
import CoreMotion
import Domain

public class CoreMotionHandler: CoreMotionHandlerInterface {
    private let coreMotionManager: CMMotionManager
    public var accelerationUpdated: ((VectorMotionData) -> Void)?
    public var gyroUpdated: ((VectorMotionData) -> Void)?
    
    public init(coreMotionManager: CMMotionManager) {
        self.coreMotionManager = coreMotionManager
        setup()
    }
    
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
            guard let acceleration = data?.acceleration else { return }
            self?.accelerationUpdated?(acceleration.vector)
        }
    }
    
    private func startGyroUpdates(operationQueue: OperationQueue) {
        guard !coreMotionManager.isGyroActive else { return }
        coreMotionManager.startGyroUpdates(to: operationQueue) { [weak self] data, error in
            if let error = error { print(error); return }
            guard let gyro = data?.rotationRate else { return }
            self?.gyroUpdated?(gyro.vector)
        }
    }
}

fileprivate extension CMAcceleration  {
    var vector: VectorMotionData {
        // 地球の標準重力加速度 (m/s^2)
        let gravityEarth: Double = 9.80665
        // Android側の基準と同じになるように重力加速度を掛けて世界標準の規格に合わせる
        return VectorMotionData(
            x: self.x * gravityEarth,
            y: self.y * gravityEarth,
            z: self.z * gravityEarth
        )
    }
}

fileprivate extension CMRotationRate {
    var vector: VectorMotionData {
        VectorMotionData(
            x: self.x,
            y: self.y,
            z: self.z
        )
    }
}
