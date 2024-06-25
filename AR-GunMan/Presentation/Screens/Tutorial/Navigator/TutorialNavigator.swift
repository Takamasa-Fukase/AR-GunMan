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
        transitionType: TutorialPresenter.TransitType,
        tutorialEndEventReceiver: PublishRelay<Void>? = nil
    ) -> UIViewController {
        let vc = TutorialViewController()
        vc.presenter = TutorialPresenter(
            navigator: TutorialNavigator(viewController: vc),
            transitionType: transitionType,
            tutorialEndEventReceiver: tutorialEndEventReceiver
        )
        return vc
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
