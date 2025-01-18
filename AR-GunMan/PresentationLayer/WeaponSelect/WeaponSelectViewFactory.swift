//
//  WeaponSelectViewFactory.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation

final class WeaponSelectViewFactory {
    static func create(weaponSelected: @escaping ((Int) -> Void)) -> WeaponSelectView {
        let viewModel = WeaponSelectViewModel(weaponResourceGetUseCase: UseCaseFactory.create())
        return WeaponSelectView(viewModel: viewModel, weaponSelected: weaponSelected)
    }
}
