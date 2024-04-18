//
//  ResultNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/18.
//

import UIKit
import PanModal

protocol ResultNavigatorInterface: AnyObject {
    func showNameRegister(vmDependency: NameRegisterViewModel.Dependency)
    func backToTop()
    func showErrorAlert(_ error: Error)
}

final class ResultNavigator: ResultNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules(totalScore: Double) -> UIViewController {
        let storyboard = UIStoryboard(name: "ResultViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ResultViewController
        vc.modalPresentationStyle = .fullScreen
        let navigator = ResultNavigator(viewController: vc)
        let viewModel = ResultViewModel(
            navigator: navigator,
            rankingRepository: RankingRepository(),
            totalScore: totalScore
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func showNameRegister(vmDependency: NameRegisterViewModel.Dependency) {
        let storyboard: UIStoryboard = UIStoryboard(name: "NameRegisterViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! NameRegisterViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.vmDependency = vmDependency
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
