//
//  TopViewFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation

final class TopViewFactory {
    static func create() -> TopView {
        let viewModel = TopViewModel(
            permissionRepository: Factory.create()
        )
        return TopView(viewModel: viewModel)
    }
}
