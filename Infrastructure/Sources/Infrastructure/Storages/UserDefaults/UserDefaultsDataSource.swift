//
//  UserDefaultsClient.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation
import Data

public final class UserDefaultsClient: UserDefaultsClientInterface {
    private struct Keys {
        static let isTutorialCompleted = "isTutorialCompleted"
    }
    
    private let defaults = UserDefaults.standard
    
    public init() {}

    public var isTutorialCompleted: Bool {
        get {
            return defaults.bool(forKey: Keys.isTutorialCompleted)
        }
        set {
            defaults.set(newValue, forKey: Keys.isTutorialCompleted)
        }
    }
}
