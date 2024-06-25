//
//  RankingNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/23.
//

import UIKit

protocol RankingNavigatorInterface {
    func dismiss()
    func showErrorAlert(_ error: Error)
}

final class RankingNavigator: RankingNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules() -> UIViewController {
        let vc = RankingViewController()
        vc.presenter = RankingPresenter(
            rankingRepository: RankingRepository(),
            navigator: RankingNavigator(viewController: vc)
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
