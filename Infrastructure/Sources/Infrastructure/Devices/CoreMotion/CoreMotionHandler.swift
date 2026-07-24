//
//  CoreMotionHandler.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/06/05.
//

import Foundation
import CoreMotion
import DeviceInterface
import Domain

public class CoreMotionHandler: CoreMotionHandlerInterface {
    public var motionUpdated: ((Motion) -> Void)?
    
    private let coreMotionManager = CMMotionManager()
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public init() {
        setup()
    }
    
    public func startDetection() {
        startAccelerometerUpdates()
        startGyroUpdates()
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
    
    private func startAccelerometerUpdates() {
        guard !coreMotionManager.isAccelerometerActive else { return }
        coreMotionManager.startAccelerometerUpdates(to: operationQueue) { [weak self] data, error in
            if let error = error { print(error); return }
            guard let acceleration = data?.acceleration else { return }
            self?.motionUpdated?(acceleration.motion)
        }
    }
    
    private func startGyroUpdates() {
        guard !coreMotionManager.isGyroActive else { return }
        coreMotionManager.startGyroUpdates(to: operationQueue) { [weak self] data, error in
            if let error = error { print(error); return }
            guard let gyro = data?.rotationRate else { return }
            self?.motionUpdated?(gyro.motion)
        }
    }
}

fileprivate extension CMAcceleration  {
    var motion: Motion {
        // 地球の標準重力加速度 (m/s^2)
        let gravityEarth: Double = 9.80665
        // Android側の基準と同じになるように重力加速度を掛けて世界標準の規格に合わせる
        return Motion(
            type: .acceleration,
            x: self.x * gravityEarth,
            y: self.y * gravityEarth,
            z: self.z * gravityEarth
        )
    }
}

fileprivate extension CMRotationRate {
    var motion: Motion {
        return Motion(
            type: .gyro,
            x: self.x,
            y: self.y,
            z: self.z
        )
    }
}
