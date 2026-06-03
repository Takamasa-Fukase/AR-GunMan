//
//  PistolInfo.swift
//  ARShooting
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

struct PistolInfo: WeaponInfo {
    let id: Int
    let nodeFileName: String
    let parentNodeName: String
    let nodeName: String
    let isGunnerHandShakingAnimationEnabled: Bool
    let isRecoilAnimationEnabled: Bool
}
