//
//  SceneDelegate.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 24/6/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TopNavigator2.assembleModules()
        window?.makeKeyAndVisible()
    }
}
