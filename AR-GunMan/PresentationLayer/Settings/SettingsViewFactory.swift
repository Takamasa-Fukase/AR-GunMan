//
//  SettingsViewFactory.swift
//  Sample_AR-GunMan_Replace_SwiftUI
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
