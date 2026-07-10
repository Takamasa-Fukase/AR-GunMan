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
    
    private let weapon: Weapon

    public init(
        weapon: Weapon
    ) {
        self.weapon = weapon
    }
    
    public func execute(newWeaponType: WeaponType) -> Response {
        weapon.change(newWeaponType: newWeaponType)
        return Response(newBulletsCount: weapon.bulletsCount)
    }
}
