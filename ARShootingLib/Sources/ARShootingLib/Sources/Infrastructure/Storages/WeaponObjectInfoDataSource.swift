//
//  WeaponObjectInfoDataSource.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

final class WeaponObjectInfoDataSource: WeaponObjectInfoDataSourceInterface {
    let list: [WeaponObjectInfo] = [
        PistolObjectInfo(
            id: 0,
            isGunnerHandShakingAnimationEnabled: true,
            isRecoilAnimationEnabled: true,
            weaponResources: PistolObjectInfo.WeaponResources(
                fileName: "pistol",
                parentObjectName: "pistolParent",
                objectName: "pistol"
            )
        ),
        BazookaObjectInfo(
            id: 1,
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
    ]
}
