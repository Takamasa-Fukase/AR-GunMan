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
    
    static func build(frame: CGRect) -> GameView<ARSCNViewRepresentable> {
        let (arShootingLibHandler, arView) = Factory.create(
            frame: frame,
            targetCount: 50
        )
        let tutorialRepository: TutorialRepositoryInterface = Factory.create()
        let weaponStore = InMemoryWeaponStore()
        let weaponRepository = WeaponRepository(weaponStore: weaponStore)
        let gameSessionStore = InMemoryGameSessionStore()
        let gameSessionRepository = GameSessionRepository(gameSessionStore: gameSessionStore)
        
        let weaponFireUseCase = WeaponFireUseCase(weaponRepository: weaponRepository)
        let weaponReloadUseCase = WeaponReloadUseCase(weaponRepository: weaponRepository)
        let weaponChangeUseCase = WeaponChangeUseCase(weaponRepository: weaponRepository)
        let gameFlowDriveUseCase = GameFlowDriveUseCase(
            gameSessionRepository: gameSessionRepository,
            tutorialRepository: tutorialRepository
        )
        let scoreAddUseCase = ScoreAddUseCase(
            weaponRepository: weaponRepository,
            gameSessionRepository: gameSessionRepository
        )
        let reloadingMotionDetectedCountHandleUseCase = ReloadingMotionDetectedCountHandleUseCase(
            gameSessionRepository: gameSessionRepository
        )
        let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface = Factory.create()
        
        let presenter = GamePresenter(
            arShootingLibHandler: arShootingLibHandler,
            soundPlayer: Factory.create(),
            coreMotionHandler: Factory.create(),
            tutorialRepository: tutorialRepository,
            gameSessionRepository: gameSessionRepository,
            weaponRepository: weaponRepository,
            weaponFireUseCase: weaponFireUseCase,
            weaponReloadUseCase: weaponReloadUseCase,
            weaponChangeUseCase: weaponChangeUseCase,
            gameFlowDriveUseCase: gameFlowDriveUseCase,
            scoreAddUseCase: scoreAddUseCase,
            reloadingMotionDetectedCountHandleUseCase: reloadingMotionDetectedCountHandleUseCase,
            weaponControlMotionHandleUseCase: weaponControlMotionHandleUseCase,
        )
        let viewModel = GameViewModel(presenter: presenter)
        arShootingLibHandler.inject(delegate: presenter)
        weaponControlMotionHandleUseCase.inject(delegate: presenter)
        return GameView(
            arView: arView,
            viewModel: viewModel
        )
    }
}
