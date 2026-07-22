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
    
    static func from(
        acceleration: Vector? = nil,
        gyro: Vector? = nil
    ) -> Self? {
        let accelerationComposite = acceleration?.getComposite(of: [.y, .z])
        let gyroComposite = gyro?.getComposite(of: [.z])
        
        if let accelerationComposite = accelerationComposite,
           let gyroComposite = gyroComposite,
           isFiringMotion(
            accelerationComposite: accelerationComposite,
            gyroComposite: gyroComposite
           ) {
            return .fire
            
        } else if let gyroComposite = gyroComposite,
                  isReloadingMotion(gyroComposite: gyroComposite) {
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
