//
//  NameRegisterNavigator.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 13/6/24.
//

import UIKit

protocol NameRegisterNavigatorInterface {
    func dismiss()
    func showErrorAlert(_ error: Error)
}

final class NameRegisterNavigator: NameRegisterNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func dismiss() {
        viewController.dismiss(animated: true)
    }
    
    func showErrorAlert(_ error: Error) {
        viewController.present(UIAlertController.errorAlert(error), animated: true)
    }
}
