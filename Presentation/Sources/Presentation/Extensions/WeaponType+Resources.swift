//
//  WeaponType+Resources.swift
//  Presentation
//
//  Created by ウルトラ深瀬 on 2026/06/30.
//

import Foundation
import Domain

public extension WeaponType {
    var resources: any WeaponResources {
        switch self {
        case .pistol:
            return PistolResources(
                appearingSound: .pistolAppear,
                firingSound: .pistolFire,
                reloadingSound: .pistolReload,
                outOfBulletsSound: .pistolOutOfBullets
            )
        case .bazooka:
            return BazookaResources(
                appearingSound: .bazookaAppear,
                firingSound: .bazookaFire,
                reloadingSound: .bazookaReload,
                bulletHitSound: .bazookaExplosion
            )
        }
    }
}
