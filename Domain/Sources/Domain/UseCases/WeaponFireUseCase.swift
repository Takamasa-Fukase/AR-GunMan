//
//  WeaponFireUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public enum WeaponFireResult {
    case success(needsAutoReload: Bool, weaponType: WeaponType)
    case failure(reason: FailureReason, weaponType: WeaponType)
    
    public enum FailureReason {
        case reloading
        case outOfBullets
    }
}

public protocol WeaponFireUseCaseInterface {
    func execute() -> WeaponFireResult
}

public final class WeaponFireUseCase: WeaponFireUseCaseInterface {
    private let weaponSession: WeaponSession

    public init(
        weaponSession: WeaponSession,
    ) {
        self.weaponSession = weaponSession
    }
    
    public func execute() -> WeaponFireResult {
        let weaponType = weaponSession.currentWeaponType
        guard !weaponSession.isReloading else {
            return .failure(reason: .reloading, weaponType: weaponType)
        }
        guard weaponSession.bulletsCount > 0 else {
            return .failure(reason: .outOfBullets, weaponType: weaponType)
        }
        weaponSession.bulletsCount -= 1
        let needsAutoReload = weaponSession.currentWeaponType.weaponInfo.spec.reloadType == .auto
        return .success(needsAutoReload: needsAutoReload, weaponType: weaponType)
    }
}
