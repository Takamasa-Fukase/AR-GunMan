//
//  WeaponRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation
import Core
import Domain

public final class WeaponRepository: WeaponRepositoryInterface {
    private let weapons: [Weapon] = WeaponDataSource.weapons
    
    public init() {}
    
    public func get(by id: Int) -> Weapon {
        guard let weapon = weapons.first(where: { $0.id == id }) else {
            fatalError("WeaponDataSourceにid: \(id)の武器が存在しません")
        }
        return weapon
    }
    
    public func getDefault() -> Weapon {
        guard let weapon = weapons.first(where: { $0.isDefault }) else {
            fatalError("WeaponDataSourceにisDefault=trueの武器が存在しません")
        }
        return weapon
    }
    
    public func getAll() -> [Weapon] {
        return weapons
    }
}
