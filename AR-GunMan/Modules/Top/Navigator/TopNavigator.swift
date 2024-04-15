//
//  TopNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/14.
//

import UIKit
import PanModal

protocol TopNavigatorInterface: AnyObject {
    func showGame()
    func showSettings()
    func showTutorial()
}

class TopNavigator: TopNavigatorInterface {
    private weak var viewController: TopViewController?
    
    init(viewController: TopViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules() -> UIViewController {
        let storyboard = UIStoryboard(name: "TopViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! TopViewController
        let navigator = TopNavigator(viewController: vc)
        let dependency = TopViewModel.Dependency(
            navigator: navigator
        )
        vc.viewModel = TopViewModel(dependency: dependency)
        
        return vc
    }
    
    func showGame() {
        let vc = GameNavigator.assembleModules()
        viewController?.present(vc, animated: true)
    }
    
    func showSettings() {
        let storyboard: UIStoryboard = UIStoryboard(name: "SettingsViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SettingsViewController
        viewController?.presentPanModal(vc)
    }
    
    func showTutorial() {
        let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! TutorialViewController
        let dependency = TutorialViewModel.Dependency(transitionType: .topPage)
        vc.viewModel = TutorialViewModel(dependency: dependency)
        viewController?.presentPanModal(vc)
    }
}
