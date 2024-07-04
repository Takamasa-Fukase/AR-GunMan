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
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        // プッシュ通知の送信許可をユーザーにリクエストするダイアログを表示
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard error == nil, granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        // カメラ（ARで使用）へのアクセス許可をユーザーにリクエストするダイアログを表示
        AVCaptureDevice.requestAccess(for: .video) { _ in }
        
        #if DEBUG
            print("Running on DEBUG")
        #else
            print("Running on RELEASE")
        #endif
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("didReceiveRegistrationToken fcmToken: \(fcmToken ?? "")")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // フォアグラウンド状態でもバナーを表示する為の設定
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .banner])
    }
    
    // プッシュ通知タップ時の処理
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
