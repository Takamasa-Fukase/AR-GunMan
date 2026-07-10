//
//  WeaponFireUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public protocol WeaponFireUseCaseInterface {
    func execute() -> WeaponFireResult
}

public final class WeaponFireUseCase: WeaponFireUseCaseInterface {
    private var weaponRepository: WeaponRepositoryInterface

    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
    }
    
    public func execute() -> WeaponFireResult {
        let result = weaponRepository.weapon.fire()
        return result
    }
}
