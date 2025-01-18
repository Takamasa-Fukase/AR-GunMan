//
//  UserDefaults+Extension.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 15/1/23.
//

import Foundation

extension UserDefaults {
    private static let defaults = UserDefaults.standard

    private enum Keys {
        static let isTutorialCompleted = "isTutorialCompleted"
    }

    static var isTutorialCompleted: Bool {
        get {
            return defaults.bool(forKey: Keys.isTutorialCompleted)
        }
        set {
            defaults.set(newValue, forKey: Keys.isTutorialCompleted)
        }
    }
}
