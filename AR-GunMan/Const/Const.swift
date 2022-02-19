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
//    case rifle = "rifle"
    case bazooka = "rocket-launcher"
}

class Const {
    //Top
    static var targetIcon: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "target")
        } else {
            return UIImage(named: "targetIcon")
        }
    }
    
    static let bulletsHoleIcon = UIImage(named: "bulletsHole")
    
    //Settings
    static let developerContactURL = "https://www.instagram.com/fukase_1783/"
    
    static let privacyPolicyURL = "http://takamasafukase.com/AR-GunMan_PrivacyPolicy.html"
    
    //Game
    static let targetCount = 50 //ゲームの的の数
    
    static let timeCount: Double = 30.00 //ゲームのタイムカウント
    
    static let playerAnimationUpdateInterval: Double = 0.2
    
    static let pistolBulletsCapacity = 7 //ピストルの装弾数（最大数）
    
    static let bazookaBulletsCapacity = 1 //バズーカの装弾数（最大数）
    
    static let pistolHitPoint: Double = 5
    
    static let bazookaHitPoint: Double = 12
    
    static let pistolSightImage = UIImage(named: "pistolSight")
    
    static let bazookaSightImage = UIImage(named: "bazookaSight")
    
    static func pistolBulletsCountImage(_ count: Int) -> UIImage? {
        return UIImage(named: "bullets\(count)")
    }
    
    static func bazookaBulletsCountImage(_ count: Int) -> UIImage? {
        return UIImage(named: "bazookaRocket\(count)")
    }
    
    static func getWeaponScore(_ weapon: WeaponTypes) -> Double {
        switch weapon {
        case .pistol:
            return pistolHitPoint
        case .bazooka:
            return bazookaHitPoint
        }
    }
}


