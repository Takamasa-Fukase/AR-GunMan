//
//  ARShootingLibBuilder.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/06/14.
//

import Foundation

public struct ARShootingLibBuilder {
    public static func build(
        frame: CGRect,
        targetCount: Int
    ) -> (ARShootingControllerInterface, ARSCNViewRepresentable) {
        let weaponObjectInfoDataSource = WeaponObjectInfoDataSource()
        let weaponRepository = WeaponRepository(
            weaponObjectInfoDataSource: weaponObjectInfoDataSource
        )
        let view = ARShootingView(
            frame: frame,
            targetCount: targetCount
        )
        let presenter = ARShootingPresenter(
            weaponRepository: weaponRepository,
            view: view,
        )
        view.inject(presenter: presenter)
        let controller = ARShootingController(
            presenter: presenter
        )
        let arView = ARSCNViewRepresentable(view: view.arView)
        return (controller, arView)
    }
}
