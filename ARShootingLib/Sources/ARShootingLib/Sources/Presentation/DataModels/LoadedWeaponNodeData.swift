//
//  LoadedWeaponNodeData.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation
import SceneKit

struct LoadedWeaponNodeData {
    let weaponId: Int
    let weaponParentNode: SCNNode
    let weaponNode: SCNNode
    let targetHitParticleNode: SCNNode?
}
