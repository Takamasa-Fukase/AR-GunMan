//
//  GameAssembler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 4/7/24.
//

import UIKit
import CoreMotion

struct GameAssembler {
    static func assembleComponents() -> UIViewController {
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        let tutorialRepository = TutorialRepository()
        let navigator = GameNavigator(viewController: vc)
        let presenter = GamePresenter(
            gameScenarioHandlingUseCase: GameScenarioHandlingUseCase(
                tutorialRepository: tutorialRepository
            ),
            weaponFireUseCase: WeaponFireUseCase(),
            weaponReloadUseCase: WeaponReloadUseCase(),
            weaponChangeUseCase: WeaponChangeUseCase(),
            targetHitHandlingUseCase: TargetHitHandlingUseCase(),
            reloadMotionDetectionCountUseCase: ReloadMotionDetectionCountUseCase(),
            navigator: navigator
        )
        vc.presenter = presenter
        vc.arContentController = ARContentController()
        vc.deviceMotionController = DeviceMotionController(coreMotionManager: CMMotionManager())
        return vc
    }
}
