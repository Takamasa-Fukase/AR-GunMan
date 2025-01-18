//
//  WeaponObjectData.swift
//  Sample_AR-GunMan_Replace
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation

struct WeaponObjectData {
    let weaponId: Int
    let objectFileName: String
    let rootObjectName: String
    let weaponObjectName: String
    let targetHitParticleFileName: String?
    let targetHitParticleRootObjectName: String?
    let isGunnerHandShakingAnimationEnabled: Bool
    let isRecoilAnimationEnabled: Bool
}
