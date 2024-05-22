//
//  SoundConst.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/19.
//

import Foundation

enum Sounds: String, CaseIterable {
    case pistolSet = "pistol-slide"
    case pistolShoot = "pistol-fire"
    case pistolOutBullets = "pistol-out-bullets"
    case pistolReload = "pistol-reload"
    case headShot = "headShot"
    case bazookaSet = "bazookaSet"
    case bazookaReload = "bazookaReload"
    case bazookaShoot = "bazookaShoot"
    case bazookaHit = "bazookaHit"
    case startWhistle = "startWhistle"
    case endWhistle = "endWhistle"
    case rankingAppear = "rankingAppear"
    case kyuiin = "kyuiin"
    case westernPistolShoot = "westernPistolShoot"
    
    var needsPlayVibration: Bool {
        return self == .pistolShoot || self == .bazookaShoot
    }
}
