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
    }

    class var isTutorialAlreadySeen: Bool {
        get {
            return defaults.bool(forKey: Keys.isTutorialAlreadySeen)
        }
        set {
            defaults.set(newValue, forKey: Keys.isTutorialAlreadySeen)
        }
    }
}
