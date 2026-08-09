//
//  RankingViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation
import Presentation

struct RankingViewBuilder {
    private init() {}

    @MainActor static func build(
        dismissRequestReceiver: DismissRequestReceiver
    ) -> RankingView {
        let viewModel = RankingViewModel(
            rankingGetUseCase: Factory.create(),
            rankingStore: RankingStore.shared
        )
        return RankingView(
            viewModel: viewModel,
            dismissRequestReceiver: dismissRequestReceiver
        )
    }
}
