//
//  WeaponSession.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public final class WeaponSession {
    var currentWeaponType: WeaponType
    var bulletsCount: Int
    var isReloading: Bool
    
    public init() {
        self.currentWeaponType = WeaponType.defaultType
        self.bulletsCount = WeaponType.defaultType.weaponInfo.spec.capacity
        self.isReloading = false
    }
    
    public func changeWeapon(newWeaponType: WeaponType) {
        currentWeaponType = newWeaponType
        bulletsCount = newWeaponType.weaponInfo.spec.capacity
        isReloading = false
    }
}
