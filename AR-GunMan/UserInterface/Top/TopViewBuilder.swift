//
//  TopViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation

struct TopViewBuilder {
    private init() {}

    @MainActor static func build() -> TopView {
        let viewModel = TopViewModel(
            cameraPermissionHandler: Factory.create(),
            soundPlayer: Factory.create()
        )
        return TopView(viewModel: viewModel)
    }
}
