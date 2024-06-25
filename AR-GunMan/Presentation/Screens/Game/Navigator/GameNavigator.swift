//
//  GameNavigator.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 20/6/24.
//

import Foundation
import PanModal
import RxCocoa
import CoreMotion

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

    static func assembleModules() -> UIViewController {
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        let tutorialRepository = TutorialRepository()
        vc.presenter = GamePresenter(
            gameUseCasesComposer: GameUseCasesComposer(useCases: .init(
                tutorialNecessityCheckUseCase: TutorialNecessityCheckUseCase(
                    tutorialRepository: tutorialRepository
                ),
                tutorialEndHandlingUseCase: TutorialEndHandlingUseCase(
                    tutorialRepository: tutorialRepository
                ),
                gameStartUseCase: GameStartUseCase(),
                gameTimerHandlingUseCase: GameTimerHandlingUseCase(),
                gameTimerEndHandlingUseCase: GameTimerEndHandlingUseCase(),
                fireMotionFilterUseCase: FireMotionFilterUseCase(),
                reloadMotionFilterUseCase: ReloadMotionFilterUseCase(),
                reloadMotionDetectionCountUseCase: ReloadMotionDetectionCountUseCase(),
                weaponFireUseCase: WeaponFireUseCase(),
                weaponReloadUseCase: WeaponReloadUseCase(),
                weaponAutoReloadFilterUseCase: WeaponAutoReloadFilterUseCase(),
                weaponChangeUseCase: WeaponChangeUseCase(),
                targetHitFilterUseCase: TargetHitFilterUseCase(),
                targetHitHandlingUseCase: TargetHitHandlingUseCase()
            )),
            navigator: GameNavigator(viewController: vc)
        )
        vc.arContentController = ARContentController()
        vc.deviceMotionController = DeviceMotionController(coreMotionManager: CMMotionManager())
        return vc
    }
    
    func showTutorialView(tutorialEndEventReceiver: PublishRelay<Void>) {
        let vc = TutorialNavigator.assembleModules(
            transitionType: .gamePage,
            tutorialEndEventReceiver: tutorialEndEventReceiver
        )
        viewController.presentPanModal(vc)
    }
    
    func showWeaponSelectView(weaponSelectEventReceiver: PublishRelay<WeaponType>) {
        let vc = WeaponSelectNavigator.assembleModules(
            weaponSelectEventReceiver: weaponSelectEventReceiver
        )
        viewController.present(vc, animated: true)
    }
    
    func dismissWeaponSelectView() {
        viewController.presentedViewController?.dismiss(animated: true)
    }
    
    func showResultView(score: Double) {
        let vc = ResultNavigator.assembleModules(score: score)
        viewController.present(vc, animated: true)
    }
}

