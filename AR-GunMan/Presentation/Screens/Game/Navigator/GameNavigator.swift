//
//  GameNavigator.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 20/6/24.
//

import Foundation
import PanModal
import RxCocoa

protocol GameNavigatorInterface {
    func showTutorialView(tutorialEndEventReceiver: PublishRelay<Void>)
    func showWeaponSelectView(weaponSelectEventReceiver: PublishRelay<WeaponType>)
    func dismissWeaponSelectView()
    func showResultView(score: Double)
}

final class GameNavigator: GameNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showTutorialView(tutorialEndEventReceiver: PublishRelay<Void>) {
        let vc = TutorialAssembler.assembleComponents(
            transitionType: .gamePage,
            tutorialEndEventReceiver: tutorialEndEventReceiver
        )
        viewController.presentPanModal(vc)
    }
    
    func showWeaponSelectView(weaponSelectEventReceiver: PublishRelay<WeaponType>) {
        let vc = WeaponSelectAssembler.assembleComponents(
            weaponSelectEventReceiver: weaponSelectEventReceiver
        )
        viewController.present(vc, animated: true)
    }
    
    func dismissWeaponSelectView() {
        viewController.presentedViewController?.dismiss(animated: true)
    }
    
    func showResultView(score: Double) {
        let vc = ResultAssembler.assembleComponents(score: score)
        viewController.present(vc, animated: true)
    }
}
