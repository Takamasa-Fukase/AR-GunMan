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
    
    public var weaponType: WeaponType {
        return weaponStore.weapon.currentType
    }
    
    public var bulletsCount: Int {
        return weaponStore.weapon.bulletsCount
    }
    
    public init(weaponStore: WeaponStoreInterface) {
        self.weaponStore = weaponStore
    }
    
    public func fire() -> WeaponFireResult {
        return weaponStore.weapon.fire()
    }
    
    public func startReload() -> WeaponReloadStartResult {
        return weaponStore.weapon.startReload()
    }
    
    public func finishReload() {
        weaponStore.weapon.finishReload()
    }
    
    public func change(to newType: WeaponType) {
        weaponStore.weapon.change(to: newType)
    }
}
