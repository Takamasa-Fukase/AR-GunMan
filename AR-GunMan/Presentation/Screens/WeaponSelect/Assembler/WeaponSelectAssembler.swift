//
//  WeaponSelectAssembler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import UIKit
import RxCocoa

struct WeaponSelectAssembler {
    static func assembleComponents(
        weaponSelectEventReceiver: PublishRelay<WeaponType>?
    ) -> UIViewController {
        let vc = WeaponSelectViewController()
        let navigator = WeaponSelectNavigator(viewController: vc)
        let presenter = WeaponSelectPresenter(
            navigator: navigator,
            weaponSelectEventReceiver: weaponSelectEventReceiver
        )
        vc.presenter = presenter
        return vc
    }
}
