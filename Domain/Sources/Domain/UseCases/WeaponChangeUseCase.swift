//
//  WeaponChangeUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public protocol WeaponChangeUseCaseInterface {
    func execute(newWeaponType: WeaponType) -> WeaponChangeUseCase.Response
}

public final class WeaponChangeUseCase: WeaponChangeUseCaseInterface {
    public struct Response {
        public let newBulletsCount: Int
    }
    
    private let weaponSession: WeaponSession

    public init(
        weaponSession: WeaponSession,
    ) {
        self.weaponSession = weaponSession
    }
    
    public func execute(newWeaponType: WeaponType) -> Response {
        weaponSession.changeWeapon(newWeaponType: newWeaponType)
        return Response(newBulletsCount: weaponSession.bulletsCount)
    }
}
