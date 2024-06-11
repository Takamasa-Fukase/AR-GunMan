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
        let storyboard = UIStoryboard(name: ResultViewController.className, bundle: nil)
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
        eventReceiver: NameRegisterEventReceiver
    ) {
        let vc = NameRegisterNavigator.assembleModules(
            score: score,
            rankingListObservable: rankingListObservable,
            eventReceiver: eventReceiver
        )
        viewController.presentPanModal(vc)
    }
    
    func backToTop() {
        let topVC = viewController.presentingViewController?.presentingViewController as! TopViewController
        topVC.dismiss(animated: false)
    }
    
    func showErrorAlert(_ error: Error) {
        viewController.present(UIAlertController.errorAlert(error), animated: true)
    }
}
