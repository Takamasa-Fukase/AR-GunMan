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
        let gameStore = InMemoryGameStore()
        let gameRepository = GameRepository(gameStore: gameStore)
        
        let weaponReloadUseCase = WeaponReloadUseCase(
            weaponRepository: weaponRepository
        )
        let weaponFireUseCase = WeaponFireUseCase(
            weaponRepository: weaponRepository,
            weaponReloadUseCase: weaponReloadUseCase
        )
        let weaponChangeUseCase = WeaponChangeUseCase(
            weaponRepository: weaponRepository,
            weaponReloadUseCase: weaponReloadUseCase
        )
        let gameFlowDriveUseCase = GameFlowDriveUseCase(
            gameRepository: gameRepository,
            tutorialRepository: tutorialRepository
        )
        let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface = Factory.create()
        
        let presenter = GamePresenter(
            arShootingLibHandler: arShootingLibHandler,
            soundPlayer: Factory.create(),
            coreMotionHandler: Factory.create(),
            tutorialRepository: tutorialRepository,
            gameRepository: gameRepository,
            weaponRepository: weaponRepository,
            weaponFireUseCase: weaponFireUseCase,
            weaponReloadUseCase: weaponReloadUseCase,
            weaponChangeUseCase: weaponChangeUseCase,
            gameFlowDriveUseCase: gameFlowDriveUseCase,
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
