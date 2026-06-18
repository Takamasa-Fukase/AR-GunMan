//
//  PistolObjectInfo.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

struct PistolObjectInfo: WeaponObjectInfo {
    typealias ParticleResources = EmptyParticleResources
    
    let id: Int
    let isGunnerHandShakingAnimationEnabled: Bool
    let isRecoilAnimationEnabled: Bool
    let weaponResources: WeaponResources
    
    struct WeaponResources: WeaponObjectResources {
        let fileName: String
        let parentObjectName: String
        let objectName: String
    }
}
