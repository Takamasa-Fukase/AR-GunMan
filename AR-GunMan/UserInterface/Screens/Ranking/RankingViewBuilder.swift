//
//  RankingViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation

struct RankingViewBuilder {
    private init() {}

    static func build(
        dismissRequestReceiver: DismissRequestReceiver
    ) -> RankingView {
        let viewModel = RankingViewModel(rankingUseCase: Factory.create())
        return RankingView(
            viewModel: viewModel,
            dismissRequestReceiver: dismissRequestReceiver
        )
    }
}
