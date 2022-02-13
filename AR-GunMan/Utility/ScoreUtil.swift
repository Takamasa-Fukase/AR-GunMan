//
//  ScoreUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/13.
//

import Foundation

class ScoreUtil {
    static func getTotalScore(pistolPoint: Double, bazookaPoint: Double) -> Double {
        let sumPoint: Double = min(pistolPoint + bazookaPoint, 100.0)
        //ランキングがバラけるようにスコアに乱数をかけて調整する
        return sumPoint * (Double.random(in: 0.9...1))
    }
}
