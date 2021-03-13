//
//  Const.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2021/02/27.
//

import Foundation
import UIKit

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
}

enum WeaponTypes: String, CaseIterable {
    case pistol = "pistol"
    case rifle = "rifle"
    case bazooka = "rocket-launcher"
}

class Const {
    
    static var targetIcon: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "target")
        } else {
            return UIImage(named: "targetIcon")
        }
    }
    
    static var bulletsHoleIcon: UIImage? {
        return UIImage(named: "bulletsHole")
    }
    
    
}


