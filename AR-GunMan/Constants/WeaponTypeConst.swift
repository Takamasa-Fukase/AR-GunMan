//
//  WeaponTypeConst.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/6/24.
//

import UIKit

final class WeaponTypeConst {
    static let pistolTypeName = "pistol"
    static let bazookaTypeName = "bazooka"
    
    static let pistolBulletsCapacity: Int = 7
    static let bazookaBulletsCapacity: Int = 1
    
    static let pistolHitPoint: Int = 5
    static let bazookaHitPoint: Int = 12
    
    static let pistolReloadWaitingTimeMillisec: Int = 0
    static let bazookaReloadWaitingTimeMillisec: Int = 3200
    
    static let pistolSightImageName = "pistolSight"
    static let bazookaSightImageName = "bazookaSight"
    
    static let pistolSightImageColorHexCode: String = UIColor.systemRed.toHexString()
    static let bazookaSightImageColorHexCode: String = UIColor.systemGreen.toHexString()
    
    static let pistolBulletsCountImageBaseName = "bullets"
    static let bazookaBulletsCountImageBaseName = "bazookaRocket"
}
