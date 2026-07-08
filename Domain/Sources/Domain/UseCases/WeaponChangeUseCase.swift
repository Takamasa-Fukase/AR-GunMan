//
//  WeaponChangeUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public struct WeaponChangeUseCaseResponse {
    public let newBulletsCount: Int
}

public protocol WeaponChangeUseCaseInterface {
    func execute(newWeaponType: WeaponType) -> WeaponChangeUseCaseResponse
}

public final class WeaponChangeUseCase: WeaponChangeUseCaseInterface {
    private let weaponSession: WeaponSession

    public init(
        weaponSession: WeaponSession,
    ) {
        self.weaponSession = weaponSession
    }
    
    public func execute(newWeaponType: WeaponType) -> WeaponChangeUseCaseResponse {
        weaponSession.changeWeapon(newWeaponType: newWeaponType)
        return WeaponChangeUseCaseResponse(
            newBulletsCount: weaponSession.bulletsCount
        )
    }
}
