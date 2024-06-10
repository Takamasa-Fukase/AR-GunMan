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
        rankingListObservable: Observable<[Ranking]>,
        eventObserver: NameRegisterEventObserver
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
        let storyboard = UIStoryboard(name: "ResultViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ResultViewController
        vc.modalPresentationStyle = .fullScreen
        let useCase = ResultUseCase(
            rankingRepository: RankingRepository(),
            replayRepository: ReplayRepository()
        )
        let navigator = ResultNavigator(viewController: vc)
        let viewModel = ResultViewModel(
            useCase: useCase,
            navigator: navigator,
            score: score
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func showNameRegister(
        score: Double,
        rankingListObservable: Observable<[Ranking]>,
        eventObserver: NameRegisterEventObserver
    ) {
        let vc = NameRegisterNavigator.assembleModules(
            score: score,
            rankingListObservable: rankingListObservable,
            eventObserver: eventObserver
        )
        // TODO: 後でiOS16からの公式ハーフモーダルに変える
        viewController.present(vc, animated: true)
//        viewController.presentPanModal(vc)
    }
    
    func backToTop() {
        let topVC = viewController.presentingViewController?.presentingViewController as! TopViewController
        topVC.dismiss(animated: false)
    }
    
    func showErrorAlert(_ error: Error) {
        viewController.present(UIAlertController.errorAlert(error), animated: true)
    }
}
