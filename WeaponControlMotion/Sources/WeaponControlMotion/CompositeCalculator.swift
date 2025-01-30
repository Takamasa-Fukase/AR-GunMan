//
//  CompositeCalculator.swift
//  WeaponControlMotion
//
//  Created by ウルトラ深瀬 on 29/5/24.
//

import Foundation

final class CompositeCalculator {
    static func getCompositeValue(x: Double, y: Double, z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
