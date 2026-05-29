//
//  WeaponInfo.swift
//  ARShooting
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

protocol WeaponInfo {
    var id: Int { get }
    var nodeFileName: String { get }
    var parentNodeName: String { get }
    var nodeName: String { get }
    var targetHitParticleFileName: String? { get }
    var targetHitParticleNodeName: String? { get }
    var isGunnerHandShakingAnimationEnabled: Bool { get }
    var isRecoilAnimationEnabled: Bool { get }
}

extension WeaponInfo {
    var targetHitParticleFileName: String? { return nil }
    var targetHitParticleNodeName: String? { return nil }
}
