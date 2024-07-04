//
//  TargetHitFilter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 3/7/24.
//

import RxSwift

final class TargetHitFilter {
    static func filter(
        collisionOccurred: Observable<CollisionInfo>
    ) -> Observable<(weaponType: WeaponType, collisionInfo: CollisionInfo)> {
        return collisionOccurred
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
    }
}
