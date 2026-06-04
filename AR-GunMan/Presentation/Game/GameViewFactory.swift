//
//  GameViewFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation
import SwiftUI
import ARShootingLib
import WeaponControlMotion
import Infrastructure

final class GameViewFactory {
    static func create(frame: CGRect) -> GameView<ARSCNViewRepresentable> {
        
        let (arShootingLibHandler, arView) = Factory.create(
            frame: frame,
            targetCount: 50
        )
        let motionDetector = WeaponControlMotionDetector()
        let viewModel = GameViewModel(
            arShootingLibHandler: arShootingLibHandler,
            tutorialRepository: Factory.create(),
            gameTimerCreateUseCase: Factory.create(),
            weaponResourceGetUseCase: Factory.create(),
            weaponActionExecuteUseCase: Factory.create()
        )
        arShootingLibHandler.inject(delegate: viewModel)
        return GameView(
            arView: arView,
            motionDetector: motionDetector,
            viewModel: viewModel
        )
    }
}
