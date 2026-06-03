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
        targetCount: Int
    ) -> ARShootingPresenter {
        let weaponInfoDataSource = WeaponInfoDataSource()
        let weaponRepository = WeaponRepository(
            weaponInfoDataSource: weaponInfoDataSource
        )
        let view = ARShootingView(frame: frame)
        let presenter = ARShootingPresenter(
            weaponRepository: weaponRepository,
            view: view,
            targetCount: targetCount
        )
        view.inject(presenter: presenter)
        return presenter
    }
}
