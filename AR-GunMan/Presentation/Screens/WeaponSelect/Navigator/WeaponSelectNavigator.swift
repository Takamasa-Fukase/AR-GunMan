//
//  WeaponSelectNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import UIKit

protocol WeaponSelectNavigatorInterface {
    func dismiss()
}

final class WeaponSelectNavigator: WeaponSelectNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func dismiss() {
        viewController.dismiss(animated: true)
    }
}
