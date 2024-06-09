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
            return "pistol"
        case .bazooka:
            return "bazooka"
        }
    }
    
    var bulletsCapacity: Int {
        switch self {
        case .pistol:
            return 7
        case .bazooka:
            return 1
        }
    }
    
    var hitPoint: Double {
        switch self {
        case .pistol:
            return 5
        case .bazooka:
            return 12
        }
    }
    
    var reloadDurationMillisec: Int {
        switch self {
        case .pistol:
            return 0
        case .bazooka:
            return 3200
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
    
    // TODO: 差し替えが終わったら削除する
    var sightImage: UIImage? {
        switch self {
        case .pistol:
            return UIImage(named: "pistolSight")
        case .bazooka:
            return UIImage(named: "bazookaSight")
        }
    }
    
    // TODO: 差し替えが終わったら削除する
    var sightImageColor: UIColor {
        switch self {
        case .pistol:
            return .systemRed
        case .bazooka:
            return .systemGreen
        }
    }
    
    var sightImageName: String {
        switch self {
        case .pistol:
            return "pistolSight"
        case .bazooka:
            return "bazookaSight"
        }
    }
    
    var sightImageColorHexCode: String {
        switch self {
        case .pistol:
            return UIColor.systemRed.toHexString()
        case .bazooka:
            return UIColor.systemGreen.toHexString()
        }
    }
    
    var targetHitParticleType: ParticleSystemTypes? {
        switch self {
        case .bazooka:
            return .bazookaExplosion
        default:
            return nil
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
    
    // TODO: 差し替えが終わったら削除する
    func bulletsCountImage(at count: Int) -> UIImage? {
        switch self {
        case .pistol:
            return UIImage(named: "bullets\(count)")
        case .bazooka:
            return UIImage(named: "bazookaRocket\(count)")
        }
    }
    
    func bulletsCountImageName(at count: Int) -> String {
        switch self {
        case .pistol:
            return "bullets\(count)"
        case .bazooka:
            return "bazookaRocket\(count)"
        }
    }
}

extension WeaponType {
    var gameObjectType: GameObjectInfo.ObjectType {
        switch self {
        case .pistol: 
            return .pistolBullet
        case .bazooka: 
            return .bazookaBullet
        }
    }
}
