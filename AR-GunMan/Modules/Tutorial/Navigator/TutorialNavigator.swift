//
//  TutorialNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import RxCocoa

protocol TutorialNavigatorInterface: AnyObject {
    func dismiss()
}

final class TutorialNavigator: TutorialNavigatorInterface {
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
        let viewModel = TutorialViewModel(
            navigator: navigator,
            transitionType: transitionType,
            tutorialEndObserver: tutorialEndObserver
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
