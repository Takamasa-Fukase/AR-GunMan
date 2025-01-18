//
//  SettingsViewFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation

final class SettingsViewFactory {
    static func create() -> SettingsView {
        let viewModel = SettingsViewModel()
        return SettingsView(viewModel: viewModel)
    }
}
