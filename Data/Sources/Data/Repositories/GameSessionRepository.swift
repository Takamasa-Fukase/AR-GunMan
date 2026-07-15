//
//  GameSessionRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation
import Domain

public final class GameSessionRepository: GameSessionRepositoryInterface {
    private var gameSessionStore: GameSessionStoreInterface
    
    public init(gameSessionStore: GameSessionStoreInterface) {
        self.gameSessionStore = gameSessionStore
    }
    
    public var session: GameSession {
        get {
            return gameSessionStore.session
        }
        set {
            gameSessionStore.session = newValue
        }
    }
}
