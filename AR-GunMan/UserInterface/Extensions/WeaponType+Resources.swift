//
//  WeaponType+Resources.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/06/30.
//

import Foundation
import Domain

extension WeaponType {
    var resources: any WeaponResources {
        switch self {
        case .pistol:
            return PistolResources(
                weaponImageName: "pistol",
                sightImageName: "pistol_sight",
                sightImageColorType: .red,
                bulletsCountImageBaseName: "pistol_bullets_"
            )
        case .bazooka:
            return BazookaResources(
                weaponImageName: "bazooka",
                sightImageName: "bazooka_sight",
                sightImageColorType: .green,
                bulletsCountImageBaseName: "bazooka_bullets_"
            )
        }
    }
}
