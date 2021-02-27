//
//  CalcuModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/08/16.
//  Copyright © 2020 fukase. All rights reserved.
//

import Foundation

class CalcuModel {
    
    static func getCompositeAcceleration(_ x: Double, _ y: Double, _ z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
    
    static func getCompositeGyro(_ x: Double, _ y: Double, _ z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
