//
//  TestData.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 5/2/25.
//

import Domain

final class GameViewModelTestsTestData {
    let pistolId = 0
    let pistolSpec = CurrentWeaponData.Spec(
        capacity: 7,
        reloadWaitingTime: 0,
        reloadType: .manual,
        targetHitPoint: 5
    )
    let pistolResources = CurrentWeaponData.Resources(
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
    
    let bazookaId = 1
    let bazookaSpec = CurrentWeaponData.Spec(
        capacity: 1,
        reloadWaitingTime: 3.2,
        reloadType: .auto,
        targetHitPoint: 12
    )
    let bazookaResources = CurrentWeaponData.Resources(
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
}
