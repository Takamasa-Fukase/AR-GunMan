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
        let targetHit: Observable<(weaponType: WeaponType, collisionInfo: CollisionInfo)>
        let currentScore: Observable<Double>
    }
    
    struct Output {
        let playTargetHitSound: Observable<SoundType>
        let updateScore: Observable<Double>
        let removeContactedTargetAndBullet: Observable<(targetId: UUID, bulletId: UUID)>
        let renderTargetHitParticleToContactPoint: Observable<(weaponType: WeaponType, contactPoint: Vector)>
    }
    
    func transform(input: Input) -> Output {
        let playTargetHitSound = input.targetHit
            .map({ $0.weaponType.hitSound })
        
        let updateScore = input.targetHit
            .withLatestFrom(input.currentScore) {
                return (weaponType: $0.weaponType, currentScore: $1)
            }
            .map({
                return ScoreCalculator.getTotalScore(
                    currentScore: $0.currentScore,
                    weaponType: $0.weaponType
                )
            })
        
        let removeContactedTargetAndBullet = input.targetHit
            .map({ (targetId: $0.collisionInfo.firstObjectInfo.id, bulletId: $0.collisionInfo.secondObjectInfo.id) })

        let renderTargetHitParticleToContactPoint = input.targetHit
            .filter({ $0.weaponType == .bazooka })
            .map({ (weaponType: $0.weaponType, contactPoint: $0.collisionInfo.contactPoint) })
        
        return Output(
            playTargetHitSound: playTargetHitSound,
            updateScore: updateScore,
            removeContactedTargetAndBullet: removeContactedTargetAndBullet,
            renderTargetHitParticleToContactPoint: renderTargetHitParticleToContactPoint
        )
    }
}
