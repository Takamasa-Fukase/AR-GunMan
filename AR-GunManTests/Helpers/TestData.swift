//
//  TestData.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 5/2/25.
//

import Domain

final class GameViewModelTestsTestData {
    let pistol = Weapon(
        id: 0,
        isDefault: true,
        spec: .init(
            capacity: 7,
            reloadWaitingTime: 0,
            reloadType: .manual,
            targetHitPoint: 5
        ),
        resources: .init(
            weaponImageName: "pistol",
            sightImageName: "pistol_sight",
            sightImageColorType: .red,
            bulletsCountImageBaseName: "pistol_bullets_",
            appearingSound: .pistolAppear,
            firingSound: .pistolFire,
            reloadingSound: .pistolReload,
            outOfBulletsSound: .pistolOutOfBullets,
            bulletHitSound: nil
        )
    )
    let bazooka = Weapon(
        id: 1,
        isDefault: false,
        spec: .init(
            capacity: 1,
            reloadWaitingTime: 3.2,
            reloadType: .auto,
            targetHitPoint: 12
        ),
        resources: .init(
            weaponImageName: "bazooka",
            sightImageName: "bazooka_sight",
            sightImageColorType: .green,
            bulletsCountImageBaseName: "bazooka_bullets_",
            appearingSound: .bazookaAppear,
            firingSound: .bazookaFire,
            reloadingSound: .bazookaReload,
            outOfBulletsSound: nil,
            bulletHitSound: .bazookaExplosion
        )
    )
}
