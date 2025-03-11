//
//  WeaponSelectViewFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation

final class WeaponSelectViewFactory {
    static func create(
        initialDisplayWeaponId: Int,
        weaponSelected: @escaping (Int) -> Void
    ) -> WeaponSelectView {
        let viewModel = WeaponSelectViewModel(
            weaponResourceGetUseCase: Factory.create(),
            initialDisplayWeaponId: initialDisplayWeaponId
        )
        return WeaponSelectView(viewModel: viewModel, weaponSelected: weaponSelected)
    }
}
