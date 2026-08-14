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

struct GameViewBuilder {
    private init() {}
    
    @MainActor
    static func build(
        frame: CGRect,
        replayButtonTapped: @escaping () -> Void
    ) -> GameView<ARSCNViewRepresentable> {
        let (arShootingLibHandler, arView) = Factory.create(
            frame: frame,
            targetCount: 50
        )
        let weaponReloadUseCase: WeaponReloadUseCaseInterface = Factory.create()
        let viewModel = GameViewModel(
            arGameEngineHandler: arShootingLibHandler,
            soundPlayer: Factory.create(),
            motionSensorHandler: Factory.create(),
            gameStore: Factory.create(),
            weaponStore: Factory.create(),
            weaponFireUseCase: Factory.create(
                weaponReloadUseCase: weaponReloadUseCase
            ),
            weaponReloadUseCase: weaponReloadUseCase,
            weaponChangeUseCase: Factory.create(
                weaponReloadUseCase: weaponReloadUseCase
            ),
            gameFlowDriveUseCase: Factory.create(),
            scoreAddUseCase: Factory.create(),
            reloadingMotionCountUpdateUseCase: Factory.create(),
            weaponControlMotionDetectUseCase: Factory.create()
        )
        return GameView(
            arView: arView,
            replayButtonTapped: replayButtonTapped,
            viewModel: viewModel
        )
    }
}
