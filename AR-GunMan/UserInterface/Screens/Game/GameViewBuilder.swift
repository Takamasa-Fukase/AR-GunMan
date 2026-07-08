//
//  GameViewBuilder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation
import SwiftUI
import ARShootingLib
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
//        let presenter = GamePresenter(
//            arShootingLibHandler: arShootingLibHandler,
//            soundPlayer: Factory.create(),
//            coreMotionHandler: Factory.create(),
//            tutorialRepository: Factory.create(),
//            weaponControlMotionHandleUseCase: weaponControlMotionHandleUseCase,
//            gameTimerCreateUseCase: Factory.create(),
//            weaponActionExecuteUseCase: Factory.create()
//        )
        
        let weaponSession = WeaponSession()
        let gameSession = GameSession()
        
        let weaponFireUseCase = WeaponFireUseCase(weaponSession: weaponSession)
        let weaponChangeUseCase = WeaponChangeUseCase(weaponSession: weaponSession)
        let scoreAddUseCase = ScoreAddUseCase(
            weaponSession: weaponSession,
            gameSession: gameSession
        )
        let scoreGetUseCase = ScoreGetUseCase(gameSession: gameSession)
        
        let presenter = GamePresenter2(
            arShootingLibHandler: arShootingLibHandler,
            soundPlayer: Factory.create(),
            coreMotionHandler: Factory.create(),
            tutorialRepository: Factory.create(),
            weaponControlMotionHandleUseCase: weaponControlMotionHandleUseCase,
            gameTimerCreateUseCase: Factory.create(),
            weaponActionExecuteUseCase: Factory.create(),
            weaponFireUseCase: weaponFireUseCase,
            weaponChangeUseCase: weaponChangeUseCase,
            scoreAddUseCase: scoreAddUseCase,
            scoreGetUseCase: scoreGetUseCase
        )
        let viewModel = GameViewModel2(presenter: presenter)
        arShootingLibHandler.inject(delegate: presenter)
        weaponControlMotionHandleUseCase.inject(delegate: presenter)
        return GameView(
            arView: arView,
            viewModel: viewModel
        )
    }
}
