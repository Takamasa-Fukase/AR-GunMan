//
//  WeaponInfoDataSource.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

final class WeaponInfoDataSource: WeaponInfoDataSourceInterface {
    let list: [WeaponInfo] = [
        PistolInfo(
            id: 0,
            nodeFileName: "pistol",
            parentNodeName: "pistolParent",
            nodeName: "pistol",
            isGunnerHandShakingAnimationEnabled: true,
            isRecoilAnimationEnabled: true
        ),
        BazookaInfo(
            id: 1,
            nodeFileName: "bazooka",
            parentNodeName: "bazookaParent",
            nodeName: "bazooka",
            targetHitParticleFileName: "bazookaExplosion",
            targetHitParticleNodeName: "bazookaExplosion",
            isGunnerHandShakingAnimationEnabled: false,
            isRecoilAnimationEnabled: false
        )
    ]
}
