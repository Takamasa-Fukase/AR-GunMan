//
//  ScoreCounter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 10/1/23.
//

import RxCocoa

class ScoreCounter {
    private let totalScoreRelay = BehaviorRelay<Double>(value: 0)
    
    var totalScore: Double {
        return totalScoreRelay.value
    }
    
    func addScore(weaponType: WeaponType) {
        let totalScore = ScoreCalculator.getTotalScore(currentScore: totalScore,
                                                       weaponType: weaponType)
        totalScoreRelay.accept(totalScore)
    }
}
