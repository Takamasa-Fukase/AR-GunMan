//
//  WeaponRepository.swift
//
//
//  Created by ウルトラ深瀬 on 18/12/24.
//

import Foundation

final class WeaponRepository: WeaponRepositoryInterface {
    private let weaponObjectDataList: [WeaponObjectData] = WeaponObjectDataSource.weaponObjectDataList
    
    func getWeaponObjectData(by id: Int) throws -> WeaponObjectData {
        guard let weaponObjectData = weaponObjectDataList.first(where: { $0.weaponId == id }) else {
            // エラーをthrowする
            throw CustomError.other(message: "武器が存在しません id: \(id)")
        }
        return weaponObjectData
    }
}
