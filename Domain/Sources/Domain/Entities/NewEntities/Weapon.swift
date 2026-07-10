//
//  Weapon.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public final class Weapon {
    var currentType: WeaponType
    var bulletsCount: Int
    var isReloading: Bool
    
    public init() {
        self.currentType = WeaponType.defaultType
        self.bulletsCount = WeaponType.defaultType.weaponInfo.spec.capacity
        self.isReloading = false
    }
    
    public func fire() -> WeaponFireResult {
        guard !isReloading else {
            return .failure(reason: .reloading)
        }
        guard bulletsCount > 0 else {
            return .failure(reason: .outOfBullets)
        }
        bulletsCount -= 1
        let needsAutoReload = currentType.weaponInfo.spec.reloadType == .auto
        return .success(needsAutoReload: needsAutoReload)
    }
    
    public func reload() -> 
    
    public func change(newWeaponType: WeaponType) {
        currentType = newWeaponType
        bulletsCount = newWeaponType.weaponInfo.spec.capacity
        isReloading = false
    }
}

public enum WeaponFireResult {
    case success(needsAutoReload: Bool)
    case failure(reason: FailureReason)
    
    public enum FailureReason {
        case reloading
        case outOfBullets
    }
}
