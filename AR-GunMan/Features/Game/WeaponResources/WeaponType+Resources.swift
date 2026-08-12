//
//  WeaponType+Resources.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/07/28.
//

import Foundation
import Domain
import SwiftUI

extension WeaponType {
    var uiResources: WeaponUIResources {
        switch self {
        case .pistol:
            return WeaponUIResources(
                weaponImageName: "pistol",
                sightImageName: "pistol_sight",
                sightImageColor: Color(uiColor: .systemRed),
                bulletsCountImageBaseName: "pistol_bullets_"
            )
        case .bazooka:
            return WeaponUIResources(
                weaponImageName: "bazooka",
                sightImageName: "bazooka_sight",
                sightImageColor: Color(uiColor: .systemGreen),
                bulletsCountImageBaseName: "bazooka_bullets_"
            )
        }
    }
    
    var soundResources: any WeaponSoundResources {
        switch self {
        case .pistol:
            return PistolSoundResources(
                appearingSound: .pistolAppear,
                firingSound: .pistolFire,
                reloadingSound: .pistolReload,
                outOfBulletsSound: .pistolOutOfBullets
            )
        case .bazooka:
            return BazookaSoundResources(
                appearingSound: .bazookaAppear,
                firingSound: .bazookaFire,
                reloadingSound: .bazookaReload,
                bulletHitSound: .bazookaExplosion
            )
        }
    }
}
