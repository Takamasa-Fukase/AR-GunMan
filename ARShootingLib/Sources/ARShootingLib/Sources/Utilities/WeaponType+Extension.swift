//
//  WeaponType+Extension.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/06/28.
//

import Foundation

extension WeaponType {
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
                )
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
                )
            )
        }
    }
}
