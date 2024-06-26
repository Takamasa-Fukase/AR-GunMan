//
//  TopNavigator2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import UIKit
import PanModal

protocol TopNavigatorInterface2 {
    func showGame()
    func showSettings()
    func showTutorial()
    func showCameraPermissionDescriptionAlert()
}

final class TopNavigator2: TopNavigatorInterface2 {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules() -> UIViewController {
        let vc = TopViewController2()
        let navigator = TopNavigator2(viewController: vc)
        let presenter = TopPresenter(
            replayNecessityCheckUseCase: ReplayNecessityCheckUseCase(
                replayRepository: ReplayRepository()
            ),
            buttonIconChangeUseCase: TopPageButtonIconChangeUseCase(),
            cameraPermissionCheckUseCase: CameraPermissionCheckUseCase(
                avPermissionRepository: AVPermissionRepository()
            ),
            navigator: navigator
        )
        vc.presenter = presenter
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
