//
//  UserDefaultsDataSource.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation
import Data

public final class UserDefaultsDataSource: UserDefaultsDataSourceInterface {
    private let defaults = UserDefaults.standard
    
    public init() {}

    private enum Keys {
        static let isTutorialCompleted = "isTutorialCompleted"
    }

    public var isTutorialCompleted: Bool {
        get {
            return defaults.bool(forKey: Keys.isTutorialCompleted)
        }
        set {
            defaults.set(newValue, forKey: Keys.isTutorialCompleted)
        }
    }
}
