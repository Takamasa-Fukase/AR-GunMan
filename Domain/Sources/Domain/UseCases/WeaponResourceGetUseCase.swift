//
//  WeaponResourceGetUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 14/11/24.
//

import Foundation

public protocol WeaponResourceGetUseCaseInterface {
    func getDefaultWeapon() -> CurrentWeapon
    func getWeapon(of weaponId: Int) -> CurrentWeapon
    func getWeaponListItems() -> [WeaponListItem]
}

public final class WeaponResourceGetUseCase {
    private let weaponRepository: WeaponRepositoryInterface
    
    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
    }
}

extension WeaponResourceGetUseCase: WeaponResourceGetUseCaseInterface {
    public func getDefaultWeapon() -> CurrentWeapon {
        let weapon = weaponRepository.getDefault()
        return CurrentWeapon(
            weapon: weapon,
            state: .init(
                bulletsCount: weapon.spec.capacity,
                isReloading: false
            )
        )
    }
    
    public func getWeapon(of weaponId: Int) -> CurrentWeapon {
        let weapon = weaponRepository.get(by: weaponId)
        return CurrentWeapon(
            weapon: weapon,
            state: .init(
                bulletsCount: weapon.spec.capacity,
                isReloading: false
            )
        )
    }
    
    public func getWeaponListItems() -> [WeaponListItem] {
        let weapons = weaponRepository.getAll()
        return weapons.map { weapon in
            return WeaponListItem(weaponId: weapon.id,
                                  weaponImageName: weapon.resources.weaponImageName)
        }
    }
}
