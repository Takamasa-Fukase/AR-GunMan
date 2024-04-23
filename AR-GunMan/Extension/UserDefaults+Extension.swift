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
        static let needsReplay = "needsReplay"
    }

    static var isTutorialAlreadySeen: Bool {
        get {
            return defaults.bool(forKey: Keys.isTutorialAlreadySeen)
        }
        set {
            defaults.set(newValue, forKey: Keys.isTutorialAlreadySeen)
        }
    }
    
    static var needsReplay: Bool {
        get {
            return defaults.bool(forKey: Keys.needsReplay)
        }
        set {
            defaults.set(newValue, forKey: Keys.needsReplay)
        }
    }
}
