//
//  AppDelegate.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/04.
//

import UIKit
import Firebase
import FirebaseMessaging
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        // プッシュ通知の送信許可をユーザーにリクエストするダイアログを表示
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        application.registerForRemoteNotifications()
        // カメラ（ARで使用）へのアクセス許可をユーザーにリクエストするダイアログを表示
        AVCaptureDevice.requestAccess(for: .video) { _ in }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
