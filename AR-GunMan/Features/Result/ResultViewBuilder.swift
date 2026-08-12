//
//  ResultViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/1/25.
//

import Foundation

struct ResultViewBuilder {
    private init() {}

    @MainActor
    static func build(
        score: Double,
        replayButtonTapped: @escaping () -> Void,
        toHomeButtonTapped: @escaping () -> Void
    ) -> ResultView {
        let viewModel = ResultViewModel(
            rankingGetUseCase: Factory.create(),
            rankingStore: Factory.create(),
            score: score
        )
        return ResultView(
            viewModel: viewModel,
            replayButtonTapped: replayButtonTapped,
            toHomeButtonTapped: toHomeButtonTapped
        )
    }
}
