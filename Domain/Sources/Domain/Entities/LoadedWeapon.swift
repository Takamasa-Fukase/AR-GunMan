//
//  LoadedWeapon.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 14/11/24.
//

import Foundation

public struct LoadedWeapon {
    public let weaponType: WeaponType
    public var bulletsCount: Int
    public var isReloading: Bool
    
    public init(
        weaponType: WeaponType,
        bulletsCount: Int,
        isReloading: Bool
    ) {
        self.weaponType = weaponType
        self.bulletsCount = bulletsCount
        self.isReloading = isReloading
    }
}
