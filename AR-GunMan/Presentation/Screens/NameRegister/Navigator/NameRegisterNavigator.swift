//
//  NameRegisterNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/20.
//

import RxSwift

protocol NameRegisterNavigatorInterface {
    func dismiss()
    func showErrorAlert(_ error: Error)
}

final class NameRegisterNavigator: NameRegisterNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules(
        score: Double,
        rankingListObservable: Observable<[Ranking]>,
        eventReceiver: NameRegisterEventReceiver
    ) -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: NameRegisterViewController.className, bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! NameRegisterViewController
        vc.modalPresentationStyle = .overCurrentContext
        let navigator = NameRegisterNavigator(viewController: vc)
        let useCase = NameRegisterUseCase(rankingRepository: RankingRepository())
        let viewModel = NameRegisterViewModel(
            navigator: navigator,
            useCase: useCase,
            score: score,
            rankingListObservable: rankingListObservable,
            eventReceiver: eventReceiver
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func dismiss() {
        viewController.dismiss(animated: true)
    }
    
    func showErrorAlert(_ error: Error) {
        viewController.present(UIAlertController.errorAlert(error), animated: true)
    }
}
