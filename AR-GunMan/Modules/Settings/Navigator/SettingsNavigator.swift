//
//  SettingsNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import Foundation
import PanModal

protocol SettingsNavigatorInterface: AnyObject {
    func showRanking()
    func showPrivacyPolicy()
    func showDeveloperContact()
    func dismiss()
}

class SettingsNavigator: SettingsNavigatorInterface {
    private weak var viewController: SettingsViewController?
    
    init(viewController: SettingsViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules() -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "SettingsViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SettingsViewController
        let navigator = SettingsNavigator(viewController: vc)
        let dependency = SettingsViewModel.Dependency(navigator: navigator)
        vc.viewModel = SettingsViewModel(dependency: dependency)
        return vc
    }
    
    func showRanking() {
        let storyboard: UIStoryboard = UIStoryboard(name: "RankingViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! RankingViewController
        viewController?.presentPanModal(vc)
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
        viewController?.dismiss(animated: true)
    }
}
