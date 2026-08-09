//
//  TutorialViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation

struct TutorialViewBuilder {
    private init() {}
    
    @MainActor static func build(
        dismissRequestReceiver: DismissRequestReceiver? = nil
    ) -> TutorialView {
        let viewModel = TutorialViewModel()
        return TutorialView(
            viewModel: viewModel,
            dismissRequestReceiver: dismissRequestReceiver
        )
    }
}
