//
//  WeaponRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation
import Domain

//public final class WeaponRepository: WeaponRepositoryInterface {
//    private let weaponDataSource: WeaponDataSourceInterface
//    
//    public init(weaponDataSource: WeaponDataSourceInterface) {
//        self.weaponDataSource = weaponDataSource
//    }
//    
//    public func get(by id: Int) -> any Weapon {
//        guard let weapon = weaponDataSource.list.first(where: { $0.id == id }) else {
//            fatalError("WeaponDataSourceにid: \(id)の武器が存在しません")
//        }
//        return weapon
//    }
//    
//    public func getDefault() -> any Weapon {
//        guard let weapon = weaponDataSource.list.first(where: { $0.isDefault }) else {
//            fatalError("WeaponDataSourceにisDefault=trueの武器が存在しません")
//        }
//        return weapon
//    }
//    
//    public func getAll() -> [any Weapon] {
//        return weaponDataSource.list
//    }
//}
