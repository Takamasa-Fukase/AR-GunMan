//
//  WeaponFireUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public struct WeaponFireResponse {
    public let weaponType: WeaponType
    public let result: WeaponFireResult
}

public protocol WeaponFireUseCaseInterface {
    func execute() -> WeaponFireResult
}

public final class WeaponFireUseCase: WeaponFireUseCaseInterface {
    private let weapon: Weapon

    public init(
        weapon: Weapon,
    ) {
        self.weapon = weapon
    }
    
    public func execute() -> WeaponFireResponse {
        let result = weapon.fire()
        return WeaponFireResponse(
            weaponType: weapon.currentType,
            result: result
        )
    }
}
