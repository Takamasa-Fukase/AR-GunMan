//
//  ResultNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/18.
//

import UIKit
import PanModal
import RxSwift

protocol ResultNavigatorInterface {
    func showNameRegister(
        score: Double,
        temporaryRankTextObservable: Observable<String>,
        eventReceiver: NameRegisterEventReceiver
    )
    func backToTop()
    func showErrorAlert(_ error: Error)
}

final class ResultNavigator: ResultNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules(score: Double) -> UIViewController {
        let vc = ResultViewController()
        vc.modalPresentationStyle = .fullScreen
        let getRankingUseCase = GetRankingUseCase(
            rankingRepository: RankingRepository2(
                apiRequestor: APIRequestor<Ranking>()
            )
        )
        vc.presenter = ResultPresenter(
            replayRepository: ReplayRepository(),
            getRankingUseCase: getRankingUseCase,
            navigator: ResultNavigator(viewController: vc),
            score: score
        )
        return vc
    }
    
    func showNameRegister(
        score: Double,
        temporaryRankTextObservable: Observable<String>,
        eventReceiver: NameRegisterEventReceiver
    ) {
        let vc = NameRegisterNavigator.assembleModules(
            score: score,
            temporaryRankTextObservable: temporaryRankTextObservable,
            eventReceiver: eventReceiver
        )
        viewController.presentPanModal(vc)
    }
    
    func backToTop() {
        let topVC = viewController.presentingViewController?.presentingViewController
        topVC?.dismiss(animated: false)
    }
    
    func showErrorAlert(_ error: Error) {
        viewController.present(UIAlertController.errorAlert(error), animated: true)
    }
}
