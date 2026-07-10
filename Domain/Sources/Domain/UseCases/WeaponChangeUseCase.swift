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
    public struct State {
        public let weaponType: WeaponType
        public let bulletsCount: Int
    }
    
    public var state: State {
        return State(
            weaponType: weaponRepository.weapon.currentType,
            bulletsCount: weaponRepository.weapon.bulletsCount
        )
    }
    
    private let weaponRepository: WeaponRepositoryInterface

    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
    }
    
    public func execute(newType: WeaponType) {
        weapon.change(newType: newType)
    }
}
