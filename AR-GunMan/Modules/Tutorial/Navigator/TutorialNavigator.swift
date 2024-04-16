//
//  TutorialNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import Foundation
import RxCocoa

protocol TutorialNavigatorInterface: AnyObject {
    func dismiss()
}

class TutorialNavigator {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules(
        transitionType: TutorialViewModel.TransitType,
        tutorialEndObserver: PublishRelay<Void>? = nil
    ) -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! TutorialViewController
        let navigator = TutorialNavigator(viewController: vc)
        let dependency = TutorialViewModel.Dependency(
            navigator: navigator,
            transitionType: transitionType,
            tutorialEndObserver: tutorialEndObserver
        )
        vc.viewModel = TutorialViewModel(dependency: dependency)
        return vc
    }
}

extension TutorialNavigator: TutorialNavigatorInterface {
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
