//
//  BazookaObjectInfo.swift
//  ARShootingEngine
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

struct BazookaObjectInfo: WeaponObjectInfo {
    let isGunnerHandShakingAnimationEnabled: Bool
    let isRecoilAnimationEnabled: Bool
    let weaponResources: WeaponResources
    let particleResources: ParticleResources?
    let bulletName: String

    struct WeaponResources: WeaponObjectResources {
        let fileName: String
        let parentObjectName: String
        let objectName: String
    }
    
    struct ParticleResources: TargetHitParticleResources {
        let fileName: String
        let objectName: String
    }
}
