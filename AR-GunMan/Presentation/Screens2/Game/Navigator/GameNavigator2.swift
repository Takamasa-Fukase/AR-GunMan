//
//  GameNavigator2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 20/6/24.
//

import Foundation
import PanModal
import RxCocoa
import CoreMotion

protocol GameNavigatorInterface2 {
    func showTutorialView(tutorialEndEventReceiver: PublishRelay<Void>)
    func showWeaponChangeView(weaponSelectEventReceiver: PublishRelay<WeaponType>)
    func dismissWeaponChangeView()
    func showResultView(score: Double)
}

final class GameNavigator2: GameNavigatorInterface2 {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    static func assembleModules() -> UIViewController {
        let vc = GameViewController2()
        vc.modalPresentationStyle = .fullScreen
        let tutorialRepository = TutorialRepository()
        let presenter = GamePresenter(
            tutorialNecessityCheckUseCase: TutorialNecessityCheckUseCase(
                tutorialRepository: tutorialRepository
            ),
            tutorialEndHandlingUseCase: TutorialEndHandlingUseCase(
                tutorialRepository: tutorialRepository
            ),
            gameStartUseCase: GameStartUseCase(),
            gameTimerHandlingUseCase: GameTimerHandlingUseCase(),
            fireMotionFilterUseCase: FireMotionFilterUseCase(),
            reloadMotionFilterUseCase: ReloadMotionFilterUseCase(),
            reloadMotionDetectionCountUseCase: ReloadMotionDetectionCountUseCase(),
            weaponFireUseCase: WeaponFireUseCase(),
            weaponReloadUseCase: WeaponReloadUseCase(),
            weaponAutoReloadFilterUseCase: WeaponAutoReloadFilterUseCase(),
            weaponChangeUseCase: WeaponChangeUseCase(),
            targetHitFilterUseCase: TargetHitFilterUseCase(),
            targetHitHandlingUseCase: TargetHitHandlingUseCase(),
            gameTimerDisposalHandlingUseCase: GameTimerDisposalHandlingUseCase(),
            navigator: GameNavigator2(viewController: vc)
        )
        let arContentController = ARContentController()
        let deviceMotionController = DeviceMotionController2(coreMotionManager: CMMotionManager())
        vc.presenter = presenter
        vc.arContentController = arContentController
        vc.deviceMotionController = deviceMotionController
        return vc
    }
    
    func showTutorialView(tutorialEndEventReceiver: PublishRelay<Void>) {
        let vc = TutorialNavigator.assembleModules(
            transitionType: .gamePage,
            tutorialEndEventReceiver: tutorialEndEventReceiver
        )
        viewController.presentPanModal(vc)
    }
    
    func showWeaponChangeView(weaponSelectEventReceiver: PublishRelay<WeaponType>) {
        let vc = WeaponChangeNavigator.assembleModules(
            weaponSelectEventReceiver: weaponSelectEventReceiver
        )
        viewController.present(vc, animated: true)
    }
    
    func dismissWeaponChangeView() {
        viewController.presentedViewController?.dismiss(animated: true)
    }
    
    func showResultView(score: Double) {
        let vc = ResultNavigator.assembleModules(score: score)
        viewController.present(vc, animated: true)
    }
}

