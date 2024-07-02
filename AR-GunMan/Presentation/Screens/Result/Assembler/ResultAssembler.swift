//
//  ResultAssembler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import UIKit

struct ResultAssembler {
    static func assembleComponents(score: Double) -> UIViewController {
        let vc = ResultViewController()
        vc.modalPresentationStyle = .fullScreen
        let getRankingUseCase = GetRankingUseCase(
            rankingRepository: RankingRepository(
                apiRequestor: APIRequestor<Ranking>()
            )
        )
        let navigator = ResultNavigator(viewController: vc)
        let presenter = ResultPresenter(
            replayRepository: ReplayRepository(),
            getRankingUseCase: getRankingUseCase,
            navigator: navigator,
            score: score
        )
        vc.presenter = presenter
        return vc
    }
}
