//
//  NameRegisterNavigator.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 13/6/24.
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
        temporaryRankTextObservable: Observable<String>,
        eventReceiver: NameRegisterEventReceiver
    ) -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: NameRegisterViewController.className, bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! NameRegisterViewController
        vc.modalPresentationStyle = .overCurrentContext
        let navigator = NameRegisterNavigator(viewController: vc)
        let useCase = NameRegisterUseCase(rankingRepository: RankingRepository())
        let viewModel = NameRegisterViewModel(
            useCase: useCase,
            navigator: navigator,
            score: score,
            temporaryRankTextObservable: temporaryRankTextObservable,
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
