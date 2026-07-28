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
    var resources: WeaponResources {
        switch self {
        case .pistol:
            return WeaponResources(
                weaponImageName: "pistol",
                sightImageName: "pistol_sight",
                sightImageColor: Color(uiColor: .systemRed),
                bulletsCountImageBaseName: "pistol_bullets_"
            )
        case .bazooka:
            return WeaponResources(
                weaponImageName: "bazooka",
                sightImageName: "bazooka_sight",
                sightImageColor: Color(uiColor: .systemGreen),
                bulletsCountImageBaseName: "bazooka_bullets_"
            )
        }
    }
}
