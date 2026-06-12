//
//  GameViewFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 19/12/24.
//

import Foundation
import SwiftUI
import ARShootingLib
import Domain
import Infrastructure

final class GameViewFactory {
    static func create(frame: CGRect) -> GameView<ARSCNViewRepresentable, GameViewModel> {
        let (arShootingLibHandler, arView) = Factory.create(
            frame: frame,
            targetCount: 50
        )
        let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface = Factory.create()
        let viewModel = GameViewModel()
        
        let presenter = GamePresenter(
            viewModel: viewModel,
            arShootingLibHandler: arShootingLibHandler,
            soundPlayer: Factory.create(),
            tutorialRepository: Factory.create(),
            weaponControlMotionHandleUseCase: weaponControlMotionHandleUseCase,
            gameTimerCreateUseCase: Factory.create(),
            weaponResourceGetUseCase: Factory.create(),
            weaponActionExecuteUseCase: Factory.create()
        )
        arShootingLibHandler.inject(delegate: presenter)
        weaponControlMotionHandleUseCase.inject(delegate: presenter)
        return GameView(
            arView: arView,
            presenter: presenter
        )
    }
}
