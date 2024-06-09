//
//  TargetHitFilter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/6/24.
//

import RxSwift
import RxCocoa

final class TargetHitFilter {
    struct Input {
        let collisionOccurred: Observable<CollisionInfo>
    }
    
    struct Output {
        let targetHit: Observable<(weaponType: WeaponType, collisionInfo: CollisionInfo)>
    }
    
    func transform(input: Input) -> Output {
        let targetHit = input.collisionOccurred
            .filter({
                return (($0.firstObjectInfo.type == .pistolBullet || $0.firstObjectInfo.type == .bazookaBullet) && $0.secondObjectInfo.type == .target)
                || (($0.secondObjectInfo.type == .pistolBullet || $0.secondObjectInfo.type == .bazookaBullet) && $0.firstObjectInfo.type == .target)
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
        
        return Output(targetHit: targetHit)
    }
}
