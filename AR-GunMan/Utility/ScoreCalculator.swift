//
//  ScoreCalculator.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 14/1/23.
//

import Foundation

class ScoreCalculator {
    static func getTotalScore(currentScore: Double,
                              weaponType: WeaponType) -> Double {
        let totalScore = min(currentScore + weaponType.hitPoint, 100.0)
        //ランキングがバラけるようにスコアに乱数をかけて調整する
        return totalScore * (Double.random(in: 0.9...1))
    }
}
