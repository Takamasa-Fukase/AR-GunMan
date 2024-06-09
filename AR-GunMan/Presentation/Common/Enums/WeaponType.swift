//
//  WeaponType.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 12/1/23.
//

import UIKit

enum WeaponType: CaseIterable {
    case pistol
    case bazooka
    
    enum ReloadType {
        case manual
        case auto
    }
    
    var name: String {
        switch self {
        case .pistol:
            return WeaponTypeConst.pistolTypeName
        case .bazooka:
            return WeaponTypeConst.bazookaTypeName
        }
    }
    
    var bulletsCapacity: Int {
        switch self {
        case .pistol:
            return WeaponTypeConst.pistolBulletsCapacity
        case .bazooka:
            return WeaponTypeConst.bazookaBulletsCapacity
        }
    }
    
    var hitPoint: Int {
        switch self {
        case .pistol:
            return WeaponTypeConst.pistolHitPoint
        case .bazooka:
            return WeaponTypeConst.bazookaHitPoint
        }
    }
    
    var reloadWaitingTimeMillisec: Int {
        switch self {
        case .pistol:
            return WeaponTypeConst.pistolReloadWaitingTimeMillisec
        case .bazooka:
            return WeaponTypeConst.bazookaReloadWaitingTimeMillisec
        }
    }
    
    var reloadType: ReloadType {
        switch self {
        case .pistol:
            return .manual
        case .bazooka:
            return .auto
        }
    }
    
    var sightImageName: String {
        switch self {
        case .pistol:
            return WeaponTypeConst.pistolSightImageName
        case .bazooka:
            return WeaponTypeConst.bazookaSightImageName
        }
    }
    
    var sightImageColorHexCode: String {
        switch self {
        case .pistol:
            return WeaponTypeConst.pistolSightImageColorHexCode
        case .bazooka:
            return WeaponTypeConst.bazookaSightImageColorHexCode
        }
    }
    
    var hitSound: SoundType {
        switch self {
        case .pistol:
            return .headShot
        case .bazooka:
            return .bazookaHit
        }
    }
    
    var firingSound: SoundType {
        switch self {
        case .pistol:
            return .pistolShoot
        case .bazooka:
            return .bazookaShoot
        }
    }
    
    var reloadingSound: SoundType {
        switch self {
        case .pistol:
            return .pistolReload
        case .bazooka:
            return .bazookaReload
        }
    }

    var weaponChangingSound: SoundType {
        switch self {
        case .pistol:
            return .pistolSet
        case .bazooka:
            return .bazookaSet
        }
    }
    
    var gameObjectType: GameObjectInfo.ObjectType {
        switch self {
        case .pistol:
            return .pistolBullet
        case .bazooka:
            return .bazookaBullet
        }
    }
    
    var targetHitParticleType: ParticleSystemType? {
        switch self {
        case .bazooka:
            return .bazookaExplosion
        default:
            return nil
        }
    }
    
    var scnAssetsPath: String {
        switch self {
        case .pistol:
            return ARContentConst.pistolScnAssetsPath
        case .bazooka:
            return ARContentConst.bazookaScnAssetsPath
        }
    }
    
    var parentNodeName: String {
        switch self {
        case .pistol:
            return ARContentConst.pistolParentNodeName
        case .bazooka:
            return ARContentConst.bazookaParentNodeName
        }
    }
    
    func bulletsCountImageName(at count: Int) -> String {
        switch self {
        case .pistol:
            return WeaponTypeConst.pistolBulletsCountImageBaseName + String(count)
        case .bazooka:
            return WeaponTypeConst.bazookaBulletsCountImageBaseName + String(count)
        }
    }
}
