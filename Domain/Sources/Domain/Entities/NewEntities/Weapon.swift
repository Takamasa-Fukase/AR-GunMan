//
//  Weapon.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public struct Weapon {
    public private(set) var currentType: WeaponType
    public private(set) var bulletsCount: Int
    public private(set) var isReloading: Bool
    
    public init() {
        self.currentType = WeaponType.defaultType
        self.bulletsCount = WeaponType.defaultType.weaponInfo.spec.capacity
        self.isReloading = false
    }
    
    mutating func fire() -> WeaponFireResult {
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
    
    mutating func startReload() -> WeaponReloadStartResult {
        guard !isReloading && bulletsCount <= 0 else {
            return .failure
        }
        isReloading = true
        return .success
    }
    
    mutating func finishReload() {
        bulletsCount = currentType.weaponInfo.spec.capacity
        isReloading = false
    }
    
    mutating func change(newType: WeaponType) {
        currentType = newType
        finishReload()
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

public enum WeaponReloadStartResult {
    case success
    case failure
}
