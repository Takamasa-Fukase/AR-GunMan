//
//  WeaponSelectViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation
import Domain

struct WeaponSelectViewBuilder {
    private init() {}

    @MainActor static func build(
        initialDisplayWeaponType: WeaponType,
        weaponSelected: @escaping (WeaponType) -> Void
    ) -> WeaponSelectView {
        let viewModel = WeaponSelectViewModel(
            initialDisplayWeaponType: initialDisplayWeaponType
        )
        return WeaponSelectView(
            viewModel: viewModel,
            weaponSelected: weaponSelected
        )
    }
}
