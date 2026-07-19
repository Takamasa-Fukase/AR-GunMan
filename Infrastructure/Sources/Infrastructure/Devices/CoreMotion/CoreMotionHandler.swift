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
    public var accelerationUpdated: ((VectorMotionData) -> Void)?
    public var gyroUpdated: ((VectorMotionData) -> Void)?
    
    private let coreMotionManager = CMMotionManager()
//    private let operationQueue: OperationQueue = {
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        return queue
//    }()
    
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
        // TODO: 後でバックグラウンドで実行されるキューにして、Presenter側をMainActorにする
        coreMotionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
            if let error = error { print(error); return }
            guard let acceleration = data?.acceleration else { return }
            self?.accelerationUpdated?(acceleration.vector)
        }
    }
    
    private func startGyroUpdates() {
        guard !coreMotionManager.isGyroActive else { return }
        // TODO: 後でバックグラウンドで実行されるキューにして、Presenter側をMainActorにする
        coreMotionManager.startGyroUpdates(to: OperationQueue.main) { [weak self] data, error in
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
