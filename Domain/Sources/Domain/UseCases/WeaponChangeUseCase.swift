//
//  WeaponChangeUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public protocol WeaponChangeUseCaseInterface {
    func execute(newWeaponType: WeaponType)
}

public final class WeaponChangeUseCase: WeaponChangeUseCaseInterface {
    private let weaponSession: WeaponSession

    public init(
        weaponSession: WeaponSession,
    ) {
        self.weaponSession = weaponSession
    }
    
    public func execute(newWeaponType: WeaponType) {
        weaponSession.changeWeapon(newWeaponType: newWeaponType)
    }
}
