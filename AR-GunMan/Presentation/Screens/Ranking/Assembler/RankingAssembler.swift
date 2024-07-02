//
//  RankingAssembler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import UIKit

struct RankingAssembler {
    static func assembleComponents() -> UIViewController {
        let vc = RankingViewController()
        let getRankingUseCase = GetRankingUseCase(
            rankingRepository: RankingRepository(
                apiRequestor: APIRequestor<Ranking>()
            )
        )
        let navigator = RankingNavigator(viewController: vc)
        let presenter = RankingPresenter(
            getRankingUseCase: getRankingUseCase,
            navigator: navigator
        )
        vc.presenter = presenter
        return vc
    }
}
