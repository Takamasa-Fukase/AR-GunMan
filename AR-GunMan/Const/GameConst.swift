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

final class GameConst {
    // ゲームの的の数
    static let targetCount = 50
    // ゲームのタイムカウント
    static let timeCount: Double = 30.00
    // ゲーム開始までの待ち時間
    static let gameStartWaitingTimeMillisec: Int = 1500
    // ゲーム終了後に結果画面へ遷移するまでの待ち時間
    static let showResultWaitingTimeMillisec: Int = 1500
    // ゲームのタイムカウントをアップデートする間隔
    static let timeCountUpdateDurationMillisec: Int = 10
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
