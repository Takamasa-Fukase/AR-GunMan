//
//  GameScore.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

struct GameScore {
    private(set) var value: Double = 0.0
    
    mutating func add(targetHitPoint: Int) {
        //ランキングがバラけるように、加算する得点自体に90%~100%の間の乱数を掛ける
        let randomlyAdjustedHitPoint = Double(targetHitPoint) * Double.random(in: 0.9...1)
        // 100を超えない様に更新する
        value = min(value + randomlyAdjustedHitPoint, 100.0)
    }
}
