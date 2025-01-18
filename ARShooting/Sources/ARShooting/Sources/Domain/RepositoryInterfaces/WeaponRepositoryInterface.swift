//
//  WeaponRepositoryInterface.swift
//
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation

protocol WeaponRepositoryInterface {
    func getWeaponObjectData(by id: Int) throws -> WeaponObjectData
}
