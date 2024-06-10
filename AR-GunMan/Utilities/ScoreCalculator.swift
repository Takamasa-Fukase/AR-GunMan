//
//  ScoreCalculator.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 14/1/23.
//

import Foundation

final class ScoreCalculator {
    static func getUpdatedScoreAfterHit(
        currentScore: Double,
        weaponType: WeaponType
    ) -> Double {
        //ランキングがバラけるように、加算する得点自体に90%~100%の間の乱数を掛ける
        let randomlyAdjustedHitPoint = Double(weaponType.hitPoint) * Double.random(in: 0.9...1)
        return min(currentScore + randomlyAdjustedHitPoint, 100.0)
    }
}
