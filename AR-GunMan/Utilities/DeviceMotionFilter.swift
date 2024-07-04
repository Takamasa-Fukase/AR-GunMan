//
//  DeviceMotionFilter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 3/7/24.
//

import RxSwift

final class DeviceMotionFilter {
    static func filterFireMotion(
        accelerationUpdated: Observable<(acceleration: Vector, latestGyro: Vector)>
    ) -> Observable<Void> {
        return accelerationUpdated
            .map{ (acceleration, gyro) in
                return (
                    CompositeCalculator.getCompositeValue(x: 0, y: acceleration.y, z: acceleration.z),
                    CompositeCalculator.getCompositeValue(x: 0, y: 0, z: gyro.z)
                )
            }
            .filter { (accelerationCompositeValue, gyroCompositeValue) in
                return accelerationCompositeValue >= 1.5 && gyroCompositeValue < 10
            }
            .mapToVoid()
    }
    
    static func filterReloadMotion(
        gyroUpdated: Observable<Vector>
    ) -> Observable<Void> {
        return gyroUpdated
            .map{ gyro in
                return CompositeCalculator.getCompositeValue(x: 0, y: 0, z: gyro.z)
            }
            .filter { gyroCompositeValue in
                gyroCompositeValue >= 10
            }
            .mapToVoid()
    }
}
