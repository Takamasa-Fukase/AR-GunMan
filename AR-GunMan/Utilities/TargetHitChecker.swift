//
//  TargetHitChecker.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 5/7/24.
//

import Foundation

final class TargetHitChecker {
    static func isTargetHit(
        firstObjectInfo: GameObjectInfo,
        secondObjectInfo: GameObjectInfo
    ) -> (result: Bool, bulletWeaponType: WeaponType?) {
        let result = GameConst.targetHitConditionPairs.contains([
            firstObjectInfo.type,
            secondObjectInfo.type
        ])
        let weaponType = extractWeaponType(firstObjectInfo, secondObjectInfo)
        return (result: result, bulletWeaponType: weaponType)
    }
    
    private static func extractWeaponType(
        _ firstObjectInfo: GameObjectInfo,
        _ secondObjectInfo: GameObjectInfo
    ) -> WeaponType? {
        if let weaponType = firstObjectInfo.type.weaponType {
            return weaponType
        }else if let weaponType = secondObjectInfo.type.weaponType {
            return weaponType
        }else {
            return nil
        }
    }
}
