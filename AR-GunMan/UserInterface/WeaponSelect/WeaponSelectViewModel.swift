//
//  WeaponSelectViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation
import Observation
import Domain
import Presentation

@MainActor
@Observable
final class WeaponSelectViewModel {
    var weaponListItems: [WeaponListItem] = []
    private let initialDisplayWeaponType: WeaponType
    
    init(
        initialDisplayWeaponType: WeaponType
    ) {
        self.initialDisplayWeaponType = initialDisplayWeaponType
    }
    
    func onViewAppear() {
        var weaponListItems = WeaponType.allCases.map({ weaponType in
            return WeaponListItem(
                weaponType: weaponType,
                weaponImageName: weaponType.resources.weaponImageName
            )
        })
        // MEMO: 今は武器が2つしかないので簡素なロジックで初期表示武器を書き換えている
        // TODO: 今後武器の種類が3つ以上に増える時は現在の武器をリストの先頭にしてそれより前のidの武器は最後尾に配置させる
        let indexOfInitialDisplayWeapon = weaponListItems.firstIndex(where: { $0.weaponType == initialDisplayWeaponType }) ?? 0
        let initialDisplayWeapon = weaponListItems[indexOfInitialDisplayWeapon]
        weaponListItems.remove(at: indexOfInitialDisplayWeapon)
        weaponListItems.insert(initialDisplayWeapon, at: 0)
        self.weaponListItems = weaponListItems
    }
}
