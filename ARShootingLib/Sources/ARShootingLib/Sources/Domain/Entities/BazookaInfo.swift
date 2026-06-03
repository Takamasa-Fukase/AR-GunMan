//
//  BazookaInfo.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

struct BazookaInfo: WeaponInfo {
    let id: Int
    let nodeFileName: String
    let parentNodeName: String
    let nodeName: String
    let targetHitParticleFileName: String?
    let targetHitParticleNodeName: String?
    let isGunnerHandShakingAnimationEnabled: Bool
    let isRecoilAnimationEnabled: Bool
}
