//
//  InMemoryGameSessionStore.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation
import Observation
import Data
import Domain

@Observable
public final class InMemoryGameSessionStore: GameSessionStoreInterface {
    public init() {}

    public var session = GameSession()
}
