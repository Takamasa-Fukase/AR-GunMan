//
//  TutorialNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import RxCocoa

protocol TutorialNavigatorInterface {
    func dismiss()
}

final class TutorialNavigator: TutorialNavigatorInterface {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules(
        transitionType: TutorialViewModel.TransitType,
        tutorialEndEventReceiver: PublishRelay<Void>? = nil
    ) -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: TutorialViewController.className, bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! TutorialViewController
        let navigator = TutorialNavigator(viewController: vc)
        let viewModel = TutorialViewModel(
            navigator: navigator,
            transitionType: transitionType,
            tutorialEndEventReceiver: tutorialEndEventReceiver
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
