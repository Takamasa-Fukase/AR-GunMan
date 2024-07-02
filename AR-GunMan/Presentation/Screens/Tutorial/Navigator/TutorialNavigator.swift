//
//  TutorialNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import UIKit

protocol TutorialNavigatorInterface {
    func dismiss()
}

final class TutorialNavigator: TutorialNavigatorInterface {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
