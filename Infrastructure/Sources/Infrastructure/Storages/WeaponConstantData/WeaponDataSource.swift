//
//  WeaponDataSource.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation
import Data
import Domain

final class WeaponDataSource: WeaponDataSourceInterface {
    let list: [any Weapon] = [
        Pistol(
            id: 0,
            isDefault: true,
            spec: Pistol.Spec(
                capacity: 7,
                reloadWaitingTime: 0,
                reloadType: .manual,
                targetHitPoint: 5
            ),
            resources: Pistol.Resources(
                weaponImageName: "pistol",
                sightImageName: "pistol_sight",
                sightImageColorType: .red,
                bulletsCountImageBaseName: "pistol_bullets_",
                appearingSound: .pistolAppear,
                firingSound: .pistolFire,
                reloadingSound: .pistolReload,
                outOfBulletsSound: .pistolOutOfBullets
            )
        ),
        Bazooka(
            id: 1,
            isDefault: false,
            spec: Bazooka.Spec(
                capacity: 1,
                reloadWaitingTime: 3.2,
                reloadType: .auto,
                targetHitPoint: 12
            ),
            resources: Bazooka.Resources(
                weaponImageName: "bazooka",
                sightImageName: "bazooka_sight",
                sightImageColorType: .green,
                bulletsCountImageBaseName: "bazooka_bullets_",
                appearingSound: .bazookaAppear,
                firingSound: .bazookaFire,
                reloadingSound: .bazookaReload,
                bulletHitSound: .bazookaExplosion
            )
        )
    ]
}
