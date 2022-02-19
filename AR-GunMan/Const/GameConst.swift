//
//  GameConst.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/19.
//

import Foundation
import UIKit

enum WeaponTypes: String, CaseIterable {
    case pistol = "pistol"
    //    case rifle = "rifle"
    case bazooka = "rocket-launcher"
}

class GameConst {
    static let targetCount = 50 //ゲームの的の数
    
    static let timeCount: Double = 30.00 //ゲームのタイムカウント
    
    static let playerAnimationUpdateInterval: Double = 0.2
    
    static let pistolBulletsCapacity = 7 //ピストルの装弾数（最大数）
    
    static let bazookaBulletsCapacity = 1 //バズーカの装弾数（最大数）
    
    static let pistolHitPoint: Double = 5
    
    static let bazookaHitPoint: Double = 12
    
    static let pistolSightImage = UIImage(named: "pistolSight")
    
    static let bazookaSightImage = UIImage(named: "bazookaSight")
    
    static func pistolBulletsCountImage(_ count: Int) -> UIImage? {
        return UIImage(named: "bullets\(count)")
    }
    
    static func bazookaBulletsCountImage(_ count: Int) -> UIImage? {
        return UIImage(named: "bazookaRocket\(count)")
    }
    
    static func getWeaponScore(_ weapon: WeaponTypes) -> Double {
        switch weapon {
        case .pistol:
            return pistolHitPoint
        case .bazooka:
            return bazookaHitPoint
        }
    }
}
