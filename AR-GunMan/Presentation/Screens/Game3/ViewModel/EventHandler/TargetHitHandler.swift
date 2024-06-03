//
//  TargetHitHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 1/6/24.
//

import RxSwift
import RxCocoa

final class TargetHitHandler {
    struct Input {
        let targetHit: Observable<WeaponType>
        let currentScore: Observable<Double>
    }
    
    struct Output {
        let playTargetHitSound: Observable<SoundType>
        let updateScore: Observable<Double>
    }
    
    func transform(input: Input) -> Output {
        let updateScore = input.targetHit
            .withLatestFrom(input.currentScore) {
                return (weaponType: $0, currentScore: $1)
            }
            .map({
                return ScoreCalculator.getTotalScore(
                    currentScore: $0.currentScore,
                    weaponType: $0.weaponType
                )
            })
        
        return Output(
            playTargetHitSound: input.targetHit.map({ $0.hitSound }),
            updateScore: updateScore
        )
    }
}
