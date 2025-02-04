//
//  RankingViewFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation

final class RankingViewFactory {
    static func create(
        dismissRequestReceiver: DismissRequestReceiver
    ) -> RankingView {
        let viewModel = RankingViewModel(rankingUseCase: UseCaseFactory.create())
        return RankingView(
            viewModel: viewModel,
            dismissRequestReceiver: dismissRequestReceiver
        )
    }
}
