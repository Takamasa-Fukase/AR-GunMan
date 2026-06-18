//
//  WeaponRepository.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation

final class WeaponRepository: WeaponRepositoryInterface {
    private let weaponObjectInfoDataSource: WeaponObjectInfoDataSourceInterface
    
    init(weaponObjectInfoDataSource: WeaponObjectInfoDataSourceInterface) {
        self.weaponObjectInfoDataSource = weaponObjectInfoDataSource
    }
    
    func getWeaponObjectInfo(by id: Int) -> any WeaponObjectInfo {
        guard let weaponObjectInfo = weaponObjectInfoDataSource.list.first(where: { $0.id == id }) else {
            fatalError("WeaponObjectInfoDataSourceにid: \(id)の武器情報が存在しません")
        }
        return weaponObjectInfo
    }
}
