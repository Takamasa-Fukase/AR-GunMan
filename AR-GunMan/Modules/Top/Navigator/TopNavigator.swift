//
//  TopNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/14.
//

import UIKit
import PanModal

protocol TopNavigatorInterface {
    func showGame()
    func showSettings()
    func showTutorial()
    func showCameraPermissionDescriptionAlert()
}

final class TopNavigator: TopNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules() -> UIViewController {
        let storyboard = UIStoryboard(name: "TopViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! TopViewController
        let useCase = TopUseCase(
            avPermissionRepository: AVPermissionRepository(),
            replayRepository: ReplayRepository()
        )
        let navigator = TopNavigator(viewController: vc)
        let viewModel = TopViewModel(
            useCase: useCase,
            navigator: navigator
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func showGame() {
        let vc = GameNavigator2.assembleModules()
        viewController.present(vc, animated: true)
    }
    
    func showSettings() {
        let vc = SettingsNavigator.assembleModules()
        viewController.presentPanModal(vc)
    }
    
    func showTutorial() {
        let vc = TutorialNavigator.assembleModules(transitionType: .topPage)
        viewController.presentPanModal(vc)
    }
    
    func showCameraPermissionDescriptionAlert() {
        let alert = UIAlertController(
            title: "Camera Permission Required",
            message: "Camera Permission is required to play this game.\nDo you want to change your settings?",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            // 設定アプリを開く
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Not now", style: .cancel)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true)
    }
}
