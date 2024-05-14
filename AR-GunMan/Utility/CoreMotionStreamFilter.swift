//
//  CoreMotionStreamFilter.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/10.
//

import RxSwift

final class CoreMotionStreamFilter {
    static func filterFiringMotionStream(
        accelerationStream: Observable<(x: Double, y: Double, z: Double)>,
        gyroStream: Observable<(x: Double, y: Double, z: Double)>
    ) -> Observable<Void> {
        return accelerationStream
            .withLatestFrom(gyroStream) { ($0, $1) }
            .map{ (acceleration, gyro) in
                return (
                    getCompositeValue(x: 0, y: acceleration.y, z: acceleration.z),
                    getCompositeValue(x: 0, y: 0, z: gyro.z)
                )
            }
            .filter { (accelerationCompositeValue, gyroCompositeValue) in
                return accelerationCompositeValue >= 1.5 && gyroCompositeValue < 10
            }
            .map({_ in})
    }
    
    static func filterReloadingMotionStream(
        gyroStream: Observable<(x: Double, y: Double, z: Double)>
    ) -> Observable<Void> {
        return gyroStream
            .map{ gyro in
                return getCompositeValue(x: 0, y: 0, z: gyro.z)
            }
            .filter { gyroCompositeValue in
                gyroCompositeValue >= 10
            }
            .map({_ in})
    }
        
    private static func getCompositeValue(x: Double, y: Double, z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
