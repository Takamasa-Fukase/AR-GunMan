//
//  WeaponControlMotionHandleUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/06/05.
//

import Foundation

public protocol WeaponControlMotionHandleUseCaseDelegate: AnyObject {
    func firingMotionDetected()
    func reloadingMotionDetected()
}

public protocol WeaponControlMotionHandleUseCaseInterface {
    func inject(delegate: WeaponControlMotionHandleUseCaseDelegate)
    func startDetection()
    func stopDetection()
}

public final class WeaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface {
    private let coreMotionHandler: CoreMotionHandlerInterface
    private var latestGyro: VectorMotionData?
    private weak var delegate: WeaponControlMotionHandleUseCaseDelegate?
    
    public init(
        coreMotionHandler: CoreMotionHandlerInterface
    ) {
        self.coreMotionHandler = coreMotionHandler
        handleUpdate()
    }
    
    public func inject(delegate: WeaponControlMotionHandleUseCaseDelegate) {
        self.delegate = delegate
    }
    
    public func startDetection() {
        coreMotionHandler.startDetection()
    }
    
    public func stopDetection() {
        coreMotionHandler.stopDetection()
    }
    
    // MARK: Privarte Methods
    private func getCompositeValue(x: Double, y: Double, z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
    
    private func handleUpdate() {
        coreMotionHandler.accelerationUpdated = { [weak self] acceleration in
            guard let self = self else { return }
            guard let latestGyro = self.latestGyro else { return }
            let accelerationCompositeValue = self.getCompositeValue(
                x: 0,
                y: acceleration.y,
                z: acceleration.z
            )
            let gyroCompositeValue = self.getCompositeValue(
                x: 0,
                y: 0,
                z: latestGyro.z
            )
            if accelerationCompositeValue >= 144.25 && gyroCompositeValue < 10 {
                self.delegate?.firingMotionDetected()
            }
        }
        coreMotionHandler.gyroUpdated = { [weak self] gyro in
            guard let self = self else { return }
            // ジャイロの値は発射モーションの判別にも使うので最新値を保持
            self.latestGyro = gyro
            
            let gyroCompositeValue = self.getCompositeValue(
                x: 0,
                y: 0,
                z: gyro.z
            )
            if gyroCompositeValue >= 10 {
                self.delegate?.reloadingMotionDetected()
            }
        }
    }
}
