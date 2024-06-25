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
        let vc = NameRegisterViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.presenter = NameRegisterPresenter(
            rankingRepository: RankingRepository(),
            navigator: NameRegisterNavigator(viewController: vc),
            score: score,
            temporaryRankTextObservable: temporaryRankTextObservable,
            eventReceiver: eventReceiver
        )
        return vc
    }
    
    func dismiss() {
        viewController.dismiss(animated: true)
    }
    
    func showErrorAlert(_ error: Error) {
        viewController.present(UIAlertController.errorAlert(error), animated: true)
    }
}
