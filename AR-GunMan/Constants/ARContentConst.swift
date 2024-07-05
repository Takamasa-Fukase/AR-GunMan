//
//  ARContentConst.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/09.
//

import Foundation

final class ARContentConst {
    static let targetScnAssetsPath = "art.scnassets/Target/target.scn"
    static let pistolScnAssetsPath = "art.scnassets/Weapon/Pistol/pistol.scn"
    static let bazookaScnAssetsPath = "art.scnassets/Weapon/Bazooka/bazooka.scn"
    static let bazookaExplosionParticleScnAssetsPath = "art.scnassets/ParticleSystem/bazookaExplosion.scn"
    
    static let bazookaExplosionParticleBirthRate: CGFloat = 300
    static let bazookaExplosionTypeName = "bazookaExplosion"
    
    static let playerAnimationUpdateInterval: Double = 0.2
    
    static let targetNodeName = "target"
    static let bulletNodeName = "bullet"
    static let pistolParentNodeName = "pistolParent"
    static let bazookaParentNodeName = "bazookaParent"
    
    static let taimeiSanImageName = "taimei-san.jpg"
}
