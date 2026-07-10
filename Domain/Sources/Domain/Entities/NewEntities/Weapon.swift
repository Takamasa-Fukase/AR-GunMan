//
//  Weapon.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public struct Weapon {
    private(set) var currentType: WeaponType
    private(set) var bulletsCount: Int
    private(set) var isReloading: Bool
    
    public init() {
        self.currentType = WeaponType.defaultType
        self.bulletsCount = WeaponType.defaultType.weaponInfo.spec.capacity
        self.isReloading = false
    }
    
    public mutating func fire() -> WeaponFireResult {
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
    
    public mutating func startReload() -> WeaponReloadStartResult {
        guard !isReloading && bulletsCount <= 0 else {
            return .failure
        }
        isReloading = true
        return .success
    }
    
    public mutating func finishReload() {
        bulletsCount = currentType.weaponInfo.spec.capacity
        isReloading = false
    }
    
    public mutating func change(newType: WeaponType) {
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
