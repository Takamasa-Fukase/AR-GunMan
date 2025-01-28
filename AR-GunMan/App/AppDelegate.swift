//
//  AppDelegate.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/1/25.
//

import UIKit
import FirebaseCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        SoundPlayer.shared.setup()
        setupFirebaseApp()
        return true
    }
    
    // 環境毎の設定を行う
    private func setupFirebaseApp() {
        let configFileName: String = {
#if DEBUG
            return "GoogleService-Info.dev"
#else
            return "GoogleService-Info"
#endif
        }()
        guard let filePath = Bundle.main.path(forResource: configFileName, ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: filePath) else {
            fatalError("FirebaseInfoPlist file was not found")
        }
        FirebaseApp.configure(options: options)
    }
}
