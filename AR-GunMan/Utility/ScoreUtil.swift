//
//  ScoreUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/13.
//

import Foundation

class ScoreUtil {
    
    static func addScore(currentScore: Double, weapon: WeaponTypes) -> Double {
        let weaponScore = GameConst.getWeaponScore(weapon)
        let sumScore: Double = min(currentScore + weaponScore, 100.0)
        //ランキングがバラけるようにスコアに乱数をかけて調整する
        return sumScore * (Double.random(in: 0.9...1))
    }
}
