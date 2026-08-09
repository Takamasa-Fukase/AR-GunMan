//
//  GameViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation
import SwiftUI
import ARShootingLib
import Data
import Domain
import Infrastructure
import Presentation

struct GameViewBuilder {
    private init() {}
    
    @MainActor static func build(frame: CGRect) -> GameView<ARSCNViewRepresentable> {
        let (arShootingLibHandler, arView) = Factory.create(
            frame: frame,
            targetCount: 50
        )
        let tutorialRepository: TutorialRepositoryInterface = Factory.create()
        let weaponStore = WeaponStore()
        let gameStore = GameStore()
        let weaponReloadUseCase = WeaponReloadUseCase(weaponStore: weaponStore)
        let weaponFireUseCase = WeaponFireUseCase(
            weaponStore: weaponStore,
            weaponReloadUseCase: weaponReloadUseCase
        )
        let weaponChangeUseCase = WeaponChangeUseCase(
            weaponStore: weaponStore,
            weaponReloadUseCase: weaponReloadUseCase
        )
        let gameFlowDriveUseCase = GameFlowDriveUseCase(
            tutorialRepository: tutorialRepository,
            gameStore: gameStore
        )
        let scoreAddUseCase = ScoreAddUseCase(gameStore: gameStore)
        let reloadingMotionCountUpdateUseCase = ReloadingMotionCountUpdateUseCase(gameStore: gameStore)
        let presenter = GamePresenter(
            arGameEngineHandler: arShootingLibHandler,
            soundPlayer: Factory.create(),
            motionSensorHandler: Factory.create(),
            tutorialRepository: tutorialRepository,
            gameStore: gameStore,
            weaponStore: weaponStore,
            weaponFireUseCase: weaponFireUseCase,
            weaponReloadUseCase: weaponReloadUseCase,
            weaponChangeUseCase: weaponChangeUseCase,
            gameFlowDriveUseCase: gameFlowDriveUseCase,
            scoreAddUseCase: scoreAddUseCase,
            reloadingMotionCountUpdateUseCase: reloadingMotionCountUpdateUseCase,
            weaponControlMotionDetectUseCase: Factory.create()
        )
        let viewModel = GameViewModel(presenter: presenter)
        return GameView(
            arView: arView,
            viewModel: viewModel
        )
    }
}
