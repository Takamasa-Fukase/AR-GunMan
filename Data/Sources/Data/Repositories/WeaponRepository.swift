//
//  WeaponRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation
import Domain

public final class WeaponRepository: WeaponRepositoryInterface {
    private var weaponStore: WeaponStoreInterface
    
    public init(weaponStore: WeaponStoreInterface) {
        self.weaponStore = weaponStore
    }
    
    public var weapon: Weapon {
        get {
            return weaponStore.weapon
        }
        set {
            weaponStore.weapon = newValue
        }
    }
}
