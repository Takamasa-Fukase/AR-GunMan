//
//  WeaponRepository.swift
//  ARShooting
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation

final class WeaponRepository: WeaponRepositoryInterface {
    private let weaponObjectDataList: [WeaponObjectData] = WeaponObjectDataSource.weaponObjectDataList
    
    func getWeaponObjectData(by id: Int) -> WeaponObjectData {
        guard let weaponObjectData = weaponObjectDataList.first(where: { $0.weaponId == id }) else {
            fatalError("WeaponObjectDataSourceにid: \(id)の武器が存在しません")
        }
        return weaponObjectData
    }
    
    func getWeaponInfo(by id: Int) -> WeaponInfo {
        guard let weaponInfo = WeaponInfoDataSource.list.first(where: { $0.id == id }) else {
            fatalError("WeaponInfoDataSourceにid: \(id)の武器情報が存在しません")
        }
        return weaponInfo
    }
}
