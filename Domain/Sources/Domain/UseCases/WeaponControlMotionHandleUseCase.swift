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
    func execute(acceleration: VectorMotionData?, gyro: VectorMotionData?)
}

public final class WeaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface {
    private var latestGyro: VectorMotionData?
    private weak var delegate: WeaponControlMotionHandleUseCaseDelegate?
    
    public init() {}
    
    public func inject(delegate: WeaponControlMotionHandleUseCaseDelegate) {
        self.delegate = delegate
    }
    
    // FIXME: 一旦動かすための暫定
    public func execute(acceleration: VectorMotionData? = nil, gyro: VectorMotionData? = nil) {
        if let acceleration = acceleration {
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
        
        if let gyro = gyro {
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
    
    // MARK: Privarte Methods
    private func getCompositeValue(x: Double, y: Double, z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
