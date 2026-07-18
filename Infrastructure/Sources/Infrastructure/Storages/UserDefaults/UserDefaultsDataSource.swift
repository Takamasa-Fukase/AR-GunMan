//
//  UserDefaultsDataSource.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation
import Combine
import Data

public final class UserDefaultsDataSource: UserDefaultsDataSourceInterface {
    public let isTutorialCompletedPublisher: AnyPublisher<Bool, Never>
    
    private let defaults = UserDefaults.standard
    private let isTutorialCompletedSubject = CurrentValueSubject<Bool, Never>(false)
    
    public init() {
        isTutorialCompletedPublisher = isTutorialCompletedSubject.eraseToAnyPublisher()
    }

    private enum Keys {
        static let isTutorialCompleted = "isTutorialCompleted"
    }

    public var isTutorialCompleted: Bool {
        get {
            return defaults.bool(forKey: Keys.isTutorialCompleted)
        }
        set {
            defaults.set(newValue, forKey: Keys.isTutorialCompleted)
            isTutorialCompletedSubject.send(newValue)
        }
    }
}
