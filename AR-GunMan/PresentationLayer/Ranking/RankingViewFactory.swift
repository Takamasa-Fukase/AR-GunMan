//
//  RankingViewFactory.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation

final class RankingViewFactory {
    static func create(
        dismissRequestReceiver: DismissRequestReceiver
    ) -> RankingView {
        let viewModel = RankingViewModel(rankingRepository: RepositoryFactory.create())
        return RankingView(
            viewModel: viewModel,
            dismissRequestReceiver: dismissRequestReceiver
        )
    }
}
