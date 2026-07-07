//
//  WeaponObjectInfo.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

protocol WeaponObjectResources {
    var fileName: String { get }
    var parentObjectName: String { get }
    var objectName: String { get }
}

protocol TargetHitParticleResources {
    var fileName: String { get }
    var objectName: String { get }
}

protocol WeaponObjectInfo {
    associatedtype WeaponResources: WeaponObjectResources
    associatedtype ParticleResources: TargetHitParticleResources
    
    var isGunnerHandShakingAnimationEnabled: Bool { get }
    var isRecoilAnimationEnabled: Bool { get }
    var weaponResources: WeaponResources { get }
    var particleResources: ParticleResources? { get }
    var bulletName: String { get }
}

extension WeaponObjectInfo {
    var particleResources: ParticleResources? { return nil }
}

struct EmptyParticleResources: TargetHitParticleResources {
    let fileName: String
    let objectName: String
}
