//
//  NameRegisterAssembler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import UIKit
import RxSwift

struct NameRegisterAssembler {
    static func assembleComponents(
        score: Double,
        temporaryRankTextObservable: Observable<String>,
        eventReceiver: NameRegisterEventReceiver
    ) -> UIViewController {
        let vc = NameRegisterViewController()
        vc.modalPresentationStyle = .overCurrentContext
        let registerRankingUseCase = RegisterRankingUseCase(
            rankingRepository: RankingRepository(apiRequestor: APIRequestor<Ranking>())
        )
        let navigator = NameRegisterNavigator(viewController: vc)
        let presenter = NameRegisterPresenter(
            registerRankingUseCase: registerRankingUseCase,
            navigator: navigator,
            score: score,
            temporaryRankTextObservable: temporaryRankTextObservable,
            eventReceiver: eventReceiver
        )
        vc.presenter = presenter
        return vc
    }
}
