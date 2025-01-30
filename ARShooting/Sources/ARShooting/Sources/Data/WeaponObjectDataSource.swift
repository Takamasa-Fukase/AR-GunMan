//
//  WeaponObjectDataSource.swift
//  ARShooting
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation

final class WeaponObjectDataSource {
    static let weaponObjectDataList: [WeaponObjectData] = [
        .init(
            weaponId: 0,
            objectFileName: "pistol",
            rootObjectName: "pistolParent",
            weaponObjectName: "pistol",
            targetHitParticleFileName: nil,
            targetHitParticleRootObjectName: nil,
            isGunnerHandShakingAnimationEnabled: true,
            isRecoilAnimationEnabled: true
        ),
        .init(
            weaponId: 1,
            objectFileName: "bazooka",
            rootObjectName: "bazookaParent",
            weaponObjectName: "bazooka",
            targetHitParticleFileName: "bazookaExplosion",
            targetHitParticleRootObjectName: "bazookaExplosion",
            isGunnerHandShakingAnimationEnabled: false,
            isRecoilAnimationEnabled: false
        )
    ]
}
