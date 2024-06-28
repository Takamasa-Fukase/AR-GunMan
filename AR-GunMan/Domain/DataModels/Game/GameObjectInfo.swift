//
//  GameObjectInfo.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 7/6/24.
//

import Foundation

struct GameObjectInfo {
    enum ObjectType {
        case target
        case pistolBullet
        case bazookaBullet
    }
    
    let type: ObjectType
    let id: UUID = UUID()
}

extension GameObjectInfo.ObjectType {
    var weaponType: WeaponType? {
        switch self {
        case .target:
            return nil
        case .pistolBullet:
            return .pistol
        case .bazookaBullet:
            return .bazooka
        }
    }
}
