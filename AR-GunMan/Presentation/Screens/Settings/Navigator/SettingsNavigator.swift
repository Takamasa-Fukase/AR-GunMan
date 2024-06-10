//
//  SettingsNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import Foundation
import PanModal

protocol SettingsNavigatorInterface {
    func showRanking()
    func showPrivacyPolicy()
    func showDeveloperContact()
    func dismiss()
}

final class SettingsNavigator: SettingsNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules() -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: SettingsViewController.className, bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SettingsViewController
        let navigator = SettingsNavigator(viewController: vc)
        let viewModel = SettingsViewModel(navigator: navigator)
        vc.viewModel = viewModel
        return vc
    }
    
    func showRanking() {
        let vc = RankingNavigator.assembleModules()
        // TODO: 後でiOS16からの公式ハーフモーダルに変える
        viewController.present(vc, animated: true)
//        viewController.presentPanModal(vc)
    }
    
    func showPrivacyPolicy() {
        SafariViewUtil.openSafariView(
            urlString: SettingsConst.privacyPolicyURL,
            vc: viewController
        )
    }
    
    func showDeveloperContact() {
        SafariViewUtil.openSafariView(
            urlString: SettingsConst.developerContactURL,
            vc: viewController
        )
    }
    
    func dismiss() {
        viewController.dismiss(animated: true)
    }
}
