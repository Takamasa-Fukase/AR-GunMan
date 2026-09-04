//
//  WeaponType.swift
//  ARShootingEngine
//
//  Created by ウルトラ深瀬 on 2026/06/28.
//

import Foundation

public enum WeaponType: CaseIterable {
    case pistol
    case bazooka
    
    var objectInfo: any WeaponObjectInfo {
        switch self {
        case .pistol:
            return PistolObjectInfo(
                isGunnerHandShakingAnimationEnabled: true,
                isRecoilAnimationEnabled: true,
                weaponResources: PistolObjectInfo.WeaponResources(
                    fileName: "pistol",
                    parentObjectName: "pistolParent",
                    objectName: "pistol"
                ),
                bulletName: "pistolBullet"
            )
        case .bazooka:
            return BazookaObjectInfo(
                isGunnerHandShakingAnimationEnabled: false,
                isRecoilAnimationEnabled: false,
                weaponResources: BazookaObjectInfo.WeaponResources(
                    fileName: "bazooka",
                    parentObjectName: "bazookaParent",
                    objectName: "bazooka"
                ),
                particleResources: BazookaObjectInfo.ParticleResources(
                    fileName: "bazookaExplosion",
                    objectName: "bazookaExplosion"
                ),
                bulletName: "bazookaBullet"
            )
        }
    }
}
