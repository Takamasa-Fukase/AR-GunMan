//
//  GameAssembler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import UIKit
import CoreMotion

struct GameAssembler {
    static func assembleComponents() -> UIViewController {
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        let tutorialRepository = TutorialRepository()
        let gameUseCasesComposer = GameUseCasesComposer(useCases: .init(
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
        ))
        let navigator = GameNavigator(viewController: vc)
        let presenter = GamePresenter(
            gameUseCasesComposer: gameUseCasesComposer,
            navigator: navigator
        )
        vc.presenter = presenter
        vc.arContentController = ARContentController()
        vc.deviceMotionController = DeviceMotionController(coreMotionManager: CMMotionManager())
        return vc
    }
}
