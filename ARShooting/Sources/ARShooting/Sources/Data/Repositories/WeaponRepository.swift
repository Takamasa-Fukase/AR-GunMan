//
//  WeaponRepository.swift
//
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation
import Core

final class WeaponRepository: WeaponRepositoryInterface {
    private let weaponObjectDataList: [WeaponObjectData] = WeaponObjectDataSource.weaponObjectDataList
    
    func getWeaponObjectData(by id: Int) -> WeaponObjectData {
        guard let weaponObjectData = weaponObjectDataList.first(where: { $0.weaponId == id }) else {
            fatalError("WeaponObjectDataSourceにid: \(id)の武器が存在しません")
        }
        return weaponObjectData
    }
}
