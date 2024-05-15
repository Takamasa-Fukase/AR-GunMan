//
//  SimpleGameNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/15.
//

import Foundation
import PanModal
import RxCocoa
import CoreMotion

protocol SimpleGameNavigatorInterface {
    
}

final class SimpleGameNavigator: SimpleGameNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    static func assembleModules() -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "SimpleGameViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SimpleGameViewController
        vc.modalPresentationStyle = .fullScreen
        
        let navigator = GameNavigator(viewController: vc)
        let viewModel = SimpleGameViewModel()
        let gameSceneController = GameSceneController()
        let coreMotionController = CoreMotionController(coreMotionManager: CMMotionManager())
        vc.viewModel = viewModel
        vc.gameSceneController = gameSceneController
        vc.coreMotionController = coreMotionController
        return vc
    }
}


