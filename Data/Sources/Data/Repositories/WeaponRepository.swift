//
//  WeaponRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation
import Domain

public final class WeaponRepository: WeaponRepositoryInterface {
    private let inMemoryWeaponStore: InMemoryWeaponStoreInterface
    
    public init(inMemoryWeaponStore: InMemoryWeaponStoreInterface) {
        self.inMemoryWeaponStore = inMemoryWeaponStore
    }
    
    public var weapon: Weapon {
        return inMemoryWeaponStore.weapon
    }
}
