//
//  WeaponRepository.swift
//  ARShooting
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation

final class WeaponRepository: WeaponRepositoryInterface {
    func getWeaponInfo(by id: Int) -> WeaponInfo {
        guard let weaponInfo = WeaponInfoDataSource.list.first(where: { $0.id == id }) else {
            fatalError("WeaponInfoDataSourceにid: \(id)の武器情報が存在しません")
        }
        return weaponInfo
    }
}
