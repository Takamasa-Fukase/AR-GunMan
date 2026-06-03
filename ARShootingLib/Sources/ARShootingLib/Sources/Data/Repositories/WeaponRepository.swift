//
//  WeaponRepository.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation

final class WeaponRepository: WeaponRepositoryInterface {
    private let weaponInfoDataSource: WeaponInfoDataSourceInterface
    
    init(weaponInfoDataSource: WeaponInfoDataSourceInterface) {
        self.weaponInfoDataSource = weaponInfoDataSource
    }
    
    func getWeaponInfo(by id: Int) -> WeaponInfo {
        guard let weaponInfo = weaponInfoDataSource.list.first(where: { $0.id == id }) else {
            fatalError("WeaponInfoDataSourceにid: \(id)の武器情報が存在しません")
        }
        return weaponInfo
    }
}
