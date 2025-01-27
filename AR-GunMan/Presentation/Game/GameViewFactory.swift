//
//  GameViewFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation
import ARShooting
import WeaponControlMotion

final class GameViewFactory {
    static func create(frame: CGRect) -> GameView {
        let arController = ARShootingController(frame: frame)
        let motionDetector = WeaponControlMotionDetector()
        let viewModel = GameViewModel(
            tutorialRepository: RepositoryFactory.create(),
            gameTimerCreateUseCase: UseCaseFactory.create(),
            weaponResourceGetUseCase: UseCaseFactory.create(),
            weaponActionExecuteUseCase: UseCaseFactory.create()
        )
        return GameView(
            arController: arController,
            motionDetector: motionDetector,
            viewModel: viewModel
        )
    }
}
