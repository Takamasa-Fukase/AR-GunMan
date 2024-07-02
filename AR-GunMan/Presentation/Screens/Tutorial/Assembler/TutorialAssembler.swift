//
//  TutorialAssembler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import UIKit
import RxCocoa

struct TutorialAssembler {
    static func assembleComponents(
        transitionType: TutorialPresenter.TransitType,
        tutorialEndEventReceiver: PublishRelay<Void>? = nil
    ) -> UIViewController {
        let vc = TutorialViewController()
        let navigator = TutorialNavigator(viewController: vc)
        let presenter = TutorialPresenter(
            navigator: navigator,
            transitionType: transitionType,
            tutorialEndEventReceiver: tutorialEndEventReceiver
        )
        vc.presenter = presenter
        return vc
    }
}
