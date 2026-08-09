//
//  Weapon.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public struct Weapon {
    public private(set) var currentType: WeaponType = .defaultType
    public private(set) var bulletsCount: Int = WeaponType.defaultType.capacity
    public private(set) var isReloading: Bool = false
    
    public init() {}
    
    mutating func fire() -> WeaponFireResult {
        guard !isReloading else {
            return .failure(reason: .reloading)
        }
        guard bulletsCount > 0 else {
            return .failure(reason: .outOfBullets)
        }
        bulletsCount -= 1
        return .success
    }
    
    mutating func startReload() -> WeaponReloadStartResult {
        guard !isReloading && bulletsCount <= 0 else {
            return .failure
        }
        isReloading = true
        return .success
    }
    
    mutating func finishReload() {
        bulletsCount = currentType.capacity
        isReloading = false
    }
    
    mutating func change(to newType: WeaponType) {
        currentType = newType
        finishReload()
    }
}

public enum WeaponFireResult: Equatable {
    case success
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
