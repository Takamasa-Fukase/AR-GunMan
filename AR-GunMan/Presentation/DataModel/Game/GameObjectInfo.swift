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
