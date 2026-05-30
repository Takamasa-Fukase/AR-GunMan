//
//  UserDefaultsDataSource.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation
import Data

final class UserDefaultsDataSource: UserDefaultsDataSourceInterface {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let isTutorialCompleted = "isTutorialCompleted"
    }

    var isTutorialCompleted: Bool {
        get {
            return defaults.bool(forKey: Keys.isTutorialCompleted)
        }
        set {
            defaults.set(newValue, forKey: Keys.isTutorialCompleted)
        }
    }
}
