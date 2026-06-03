//
//  WeaponRepositoryInterface.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation

protocol WeaponRepositoryInterface {
    func getWeaponInfo(by id: Int) -> WeaponInfo
}
