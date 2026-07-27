//
//  WeaponControlMotion.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/22.
//

import Foundation

public enum WeaponControlMotion {
    case fire
    case reload
    
    static func from(acceleration: PhysicalMotion, gyro: PhysicalMotion?) -> Self? {
        let accelerationComposite = acceleration.getCompositeValue(of: [.y, .z])
        let gyroComposite = gyro?.getCompositeValue(of: [.z]) ?? 0.0
        if isFiringMotion(accelerationComposite: accelerationComposite, gyroComposite: gyroComposite) {
            return .fire
        } else {
            return nil
        }
    }
    
    static func from(gyro: PhysicalMotion) -> Self? {
        let gyroComposite = gyro.getCompositeValue(of: [.z])
        if isReloadingMotion(gyroComposite: gyroComposite) {
            return .reload
        } else {
            return nil
        }
    }
    
    private static func isFiringMotion(
        accelerationComposite: Double,
        gyroComposite: Double
    ) -> Bool {
        return accelerationComposite >= 144.25 && gyroComposite < 10
    }
    
    private static func isReloadingMotion(
        gyroComposite: Double
    ) -> Bool {
        return gyroComposite >= 10
    }
}
