//
//  UserDefaults+Extension.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 15/1/23.
//

import Foundation

extension UserDefaults {
    static let defaults = UserDefaults.standard

    private enum Keys {
        static let isTutorialAlreadySeen = "tutorialAlreadySeen"
        static let isReplay = "isReplay"
    }

    class var isTutorialAlreadySeen: Bool {
        get {
            return defaults.bool(forKey: Keys.isTutorialAlreadySeen)
        }
        set {
            defaults.set(newValue, forKey: Keys.isTutorialAlreadySeen)
        }
    }
    
    class var isReplay: Bool {
        get {
            return defaults.bool(forKey: Keys.isReplay)
        }
        set {
            defaults.set(newValue, forKey: Keys.isReplay)
        }
    }
}
