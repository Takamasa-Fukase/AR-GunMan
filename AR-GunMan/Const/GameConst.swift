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
    case bazooka = "bazooka"
    
    var targetHitParticleType: ParticleSystemTypes? {
        switch self {
        case .bazooka:
            return .bazookaExplosion
        default:
            return nil
        }
    }
}

enum ParticleSystemTypes: String {
    case bazookaExplosion = "bazookaExplosion"
    
    var birthRate: CGFloat {
        switch self {
        case .bazookaExplosion:
            return 300
        }
    }
}

class GameConst {
    static let targetCount = 50 //ゲームの的の数
    
    static let timeCount: Double = 30.00 //ゲームのタイムカウント
    
    static let playerAnimationUpdateInterval: Double = 0.2
    
    static let pistolBulletsCapacity = 7 //ピストルの装弾数（最大数）
    
    static let bazookaBulletsCapacity = 1 //バズーカの装弾数（最大数）
    
    static let pistolHitPoint: Double = 5
    
    static let bazookaHitPoint: Double = 12

    static let targetNodeName = "target"
    
    static let bulletNodeName = "bullet"

    static let pistolSightImage = UIImage(named: "pistolSight")
    
    static let pistolSightImageColor = UIColor.systemRed
    
    static let bazookaSightImage = UIImage(named: "bazookaSight")
    
    static let bazookaSightImageColor = UIColor.systemGreen
    
    static let taimeiSanImage = UIImage(named: "taimei-san.jpg")
    
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
    
    static func getWeaponScnAssetsPath(_ weapon: WeaponType) -> String {
        let weaponPath = "art.scnassets/Weapon/"
        switch weapon {
        case .pistol:
            return weaponPath + "Pistol/" + weapon.name + ".scn"
        case .bazooka:
            return weaponPath + "Bazooka/" + weapon.name + ".scn"
        }
    }
    
    static func getTargetScnAssetsPath() -> String {
        let targetPath = "art.scnassets/Target/"
        return targetPath + targetNodeName + ".scn"
    }
    
    static func getParticleSystemScnAssetsPath(_ particleSystem: ParticleSystemTypes) -> String {
        let particleSystemPath = "art.scnassets/ParticleSystem/"
        switch particleSystem {
        case .bazookaExplosion:
            return particleSystemPath + particleSystem.rawValue + ".scn"
        }
    }
}
