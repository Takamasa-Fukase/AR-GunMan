//
//  TargetHitFilterUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct TargetHitFilterInput {
    let collisionOccurred: Observable<CollisionInfo>
}

struct TargetHitFilterOutput {
    let targetHit: Observable<(weaponType: WeaponType, collisionInfo: CollisionInfo)>
}

protocol TargetHitFilterUseCaseInterface {
    func transform(input: TargetHitFilterInput) -> TargetHitFilterOutput
}

final class TargetHitFilterUseCase: TargetHitFilterUseCaseInterface {
    func transform(input: TargetHitFilterInput) -> TargetHitFilterOutput {
        let targetHit = input.collisionOccurred
            .filter({
                return GameConst.targetHitConditionPairs.contains(
                    [$0.firstObjectInfo.type, $0.secondObjectInfo.type]
                )
            })
            .map({
                if let weaponType = $0.firstObjectInfo.type.weaponType {
                    return (weaponType: weaponType, collisionInfo: $0)
                }else if let weaponType = $0.secondObjectInfo.type.weaponType {
                    return (weaponType: weaponType, collisionInfo: $0)
                }else {
                    return (weaponType: .pistol, collisionInfo: $0)
                }
            })
        
        return TargetHitFilterOutput(
            targetHit: targetHit
        )
    }
}
