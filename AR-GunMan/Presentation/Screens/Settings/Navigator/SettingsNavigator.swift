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
    
    func showRanking() {
        let vc = RankingAssembler.assembleComponents()
        viewController.presentPanModal(vc)
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
