//
//  ResultViewFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation

final class ResultViewFactory {
    static func create(
        score: Double,
        replayButtonTapped: @escaping () -> Void,
        toHomeButtonTapped: @escaping () -> Void
    ) -> ResultView {
        let viewModel = ResultViewModel(
            rankingRepository: RepositoryFactory.create(),
            score: score
        )
        return ResultView(
            viewModel: viewModel,
            replayButtonTapped: replayButtonTapped,
            toHomeButtonTapped: toHomeButtonTapped
        )
    }
}
