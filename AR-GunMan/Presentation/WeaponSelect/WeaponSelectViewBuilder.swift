//
//  WeaponSelectViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation

struct WeaponSelectViewBuilder {
    private init() {}

    static func build(
        initialDisplayWeaponId: Int,
        weaponSelected: @escaping (Int) -> Void
    ) -> WeaponSelectView {
        let viewModel = WeaponSelectViewModel(
            weaponResourceGetUseCase: Factory.create(),
            initialDisplayWeaponId: initialDisplayWeaponId
        )
        return WeaponSelectView(
            viewModel: viewModel,
            weaponSelected: weaponSelected
        )
    }
}
