//
//  WeaponChangeUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public protocol WeaponChangeUseCaseInterface {
    func execute(newType: WeaponType)
}

public final class WeaponChangeUseCase: WeaponChangeUseCaseInterface {
    
    private var weaponRepository: WeaponRepositoryInterface

    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
    }
    
    public func execute(newType: WeaponType) {
        weaponRepository.weapon.change(newType: newType)
    }
}
