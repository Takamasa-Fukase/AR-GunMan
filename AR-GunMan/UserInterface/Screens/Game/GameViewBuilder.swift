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
        let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface = Factory.create()
        let weaponStore = InMemoryWeaponStore()
        let weaponRepository = WeaponRepository(weaponStore: weaponStore)
        let gameSession = GameSession()
        
        let weaponFireUseCase = WeaponFireUseCase(weaponRepository: weaponRepository)
        let weaponReloadUseCase = WeaponReloadUseCase(weaponRepository: weaponRepository)
        let weaponChangeUseCase = WeaponChangeUseCase(weaponRepository: weaponRepository)
        let scoreAddUseCase = ScoreAddUseCase(
            weaponRepository: weaponRepository,
            gameSession: gameSession
        )
        let scoreGetUseCase = ScoreGetUseCase(gameSession: gameSession)
        
        let presenter = GamePresenter(
            arShootingLibHandler: arShootingLibHandler,
            soundPlayer: Factory.create(),
            coreMotionHandler: Factory.create(),
            tutorialRepository: Factory.create(),
            weaponControlMotionHandleUseCase: weaponControlMotionHandleUseCase,
            gameTimerCreateUseCase: Factory.create(),
            weaponRepository: weaponRepository,
            weaponFireUseCase: weaponFireUseCase,
            weaponReloadUseCase: weaponReloadUseCase,
            weaponChangeUseCase: weaponChangeUseCase,
            scoreAddUseCase: scoreAddUseCase,
            scoreGetUseCase: scoreGetUseCase
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
