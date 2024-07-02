//
//  SettingsAssembler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import UIKit

struct SettingsAssembler {
    static func assembleComponents() -> UIViewController {
        let vc = SettingsViewController()
        let navigator = SettingsNavigator(viewController: vc)
        let presenter = SettingsPresenter(
            navigator: navigator
        )
        vc.presenter = presenter
        return vc
    }
}
