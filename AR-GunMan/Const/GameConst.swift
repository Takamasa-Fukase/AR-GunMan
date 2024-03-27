//
//  GameConst.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/19.
//

import UIKit

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
    
    static let timeCount: Double = 3.00 //ゲームのタイムカウント
    
    static let playerAnimationUpdateInterval: Double = 0.2

    static let targetNodeName = "target"
    
    static let bulletNodeName = "bullet"

    static let taimeiSanImage = UIImage(named: "taimei-san.jpg")

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
