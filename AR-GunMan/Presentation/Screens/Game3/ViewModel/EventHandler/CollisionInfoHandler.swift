//
//  CollisionInfoHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/6/24.
//

import RxSwift
import RxCocoa

final class CollisionInfoHandler {
    struct Input {
        let collisionOccurred: Observable<CollisionInfo>
    }
    
    struct Output {
        let targetHit: Observable<WeaponType>
        let removeContactedTargetAndBullet: Observable<(targetId: UUID, bulletId: UUID)>
        let renderTargetHitParticleToContactPoint: Observable<(weaponType: WeaponType, contactPoint: Vector)>
    }
    
    func transform(input: Input) -> Output {
        let targetHit = input.collisionOccurred
            .filter({
                return (($0.firstObjectInfo.type == .pistolBullet || $0.firstObjectInfo.type == .bazookaBullet) && $0.secondObjectInfo.type == .target)
                || (($0.secondObjectInfo.type == .pistolBullet || $0.secondObjectInfo.type == .bazookaBullet) && $0.firstObjectInfo.type == .target)
            })
            .map({
                if let weaponType = $0.firstObjectInfo.type.weaponType {
                    return weaponType
                }else if let weaponType = $0.secondObjectInfo.type.weaponType {
                    return weaponType
                }else {
                    return .pistol
                }
            })
            .share()
        
        let removeContactedTargetAndBullet = targetHit
            .withLatestFrom(input.collisionOccurred)
            .map({ (targetId: $0.firstObjectInfo.id, bulletId: $0.secondObjectInfo.id) })

        let renderTargetHitParticleToContactPoint = targetHit
            .filter({ $0 == .bazooka })
            .withLatestFrom(input.collisionOccurred) { (weaponType: $0, contactPoint: $1.contactPoint) }
        
        return Output(
            targetHit: targetHit,
            removeContactedTargetAndBullet: removeContactedTargetAndBullet,
            renderTargetHitParticleToContactPoint: renderTargetHitParticleToContactPoint
        )
    }
}
