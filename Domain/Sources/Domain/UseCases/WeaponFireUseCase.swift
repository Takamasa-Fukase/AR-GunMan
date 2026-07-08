//
//  WeaponFireUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public enum WeaponFireResult {
    case success(needsAutoReload: Bool)
    case failure(reason: FailureReason)
    
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
        guard !weaponSession.isReloading else {
            return .failure(reason: .reloading)
        }
        guard weaponSession.bulletsCount > 0 else {
            return .failure(reason: .outOfBullets)
        }
        weaponSession.bulletsCount -= 1
        let needsAutoReload = weaponSession.currentWeaponType.weaponInfo.spec.reloadType == .auto
        return .success(needsAutoReload: needsAutoReload)
    }
}
