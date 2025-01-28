//
//  AR_GunManApp.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import SwiftUI

@main
struct AR_GunManApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TopViewFactory.create()
        }
    }
}
