//
//  ScoreGetUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public protocol ScoreGetUseCaseInterface {
    func execute() -> Double
}

public final class ScoreGetUseCase: ScoreGetUseCaseInterface {
    private let gameSession: GameSession

    public init(
        gameSession: GameSession
    ) {
        self.gameSession = gameSession
    }
    
    public func execute() -> Double {
        return gameSession.score.value
    }
}
