//
//  WeaponRepositoryInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation

public protocol WeaponRepositoryInterface {
    func get(by id: Int) -> any Weapon
    func getDefault() -> any Weapon
    func getAll() -> [any Weapon]
}
