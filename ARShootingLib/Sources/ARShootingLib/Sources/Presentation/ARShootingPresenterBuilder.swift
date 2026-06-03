//
//  ARShootingPresenterBuilder.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

struct ARShootingPresenterBuilder {
    static func build(
        frame: CGRect,
        delegate: ARShootingDelegate,
        targetCount: Int
    ) -> ARShootingPresenter {
        let weaponInfoDataSource = WeaponInfoDataSource()
        let weaponRepository = WeaponRepository(
            weaponInfoDataSource: weaponInfoDataSource
        )
        let view = ARShootingView(
            frame: frame,
            delegate: delegate
        )
        return ARShootingPresenter(
            weaponRepository: weaponRepository,
            view: view,
            targetCount: targetCount
        )
    }
}
