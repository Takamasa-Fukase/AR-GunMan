//
//  WeaponRepositoryInterface.swift
//  WeaponFiringSimulator
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation

public protocol WeaponRepositoryInterface {
    func get(by id: Int) throws -> Weapon
    func getDefault() throws -> Weapon
    func getAll() -> [Weapon]
}
