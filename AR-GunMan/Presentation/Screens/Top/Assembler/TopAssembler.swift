//
//  TopAssembler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import UIKit

struct TopAssembler {
    static func assembleComponents() -> UIViewController {
        let vc = TopViewController()
        let navigator = TopNavigator(viewController: vc)
        let presenter = TopPresenter(
            replayNecessityCheckUseCase: ReplayNecessityCheckUseCase(
                replayRepository: ReplayRepository()
            ),
            buttonIconChangeUseCase: TopPageButtonIconChangeUseCase(),
            cameraPermissionCheckUseCase: CameraPermissionCheckUseCase(),
            navigator: navigator
        )
        vc.presenter = presenter
        return vc
    }
}
