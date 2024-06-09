//
//  ParticleSystemType.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/6/24.
//

import Foundation

enum ParticleSystemType: String {
    case bazookaExplosion
    
    var name: String {
        switch self {
        case .bazookaExplosion:
            return ARContentConst.bazookaExplosionTypeName
        }
    }
    
    var birthRate: CGFloat {
        switch self {
        case .bazookaExplosion:
            return ARContentConst.bazookaExplosionParticleBirthRate
        }
    }
    
    var scnAssetsPath: String {
        switch self {
        case .bazookaExplosion:
            return ARContentConst.bazookaExplosionParticleScnAssetsPath
        }
    }
}
