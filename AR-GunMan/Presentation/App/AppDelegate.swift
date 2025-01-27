//
//  AppDelegate.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/1/25.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        SoundPlayer.shared.setup()
        return true
    }
}
