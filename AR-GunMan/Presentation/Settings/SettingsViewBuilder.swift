//
//  SettingsViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation

struct SettingsViewBuilder {
    private init() {}

    static func build() -> SettingsView {
        let viewModel = SettingsViewModel()
        return SettingsView(viewModel: viewModel)
    }
}
