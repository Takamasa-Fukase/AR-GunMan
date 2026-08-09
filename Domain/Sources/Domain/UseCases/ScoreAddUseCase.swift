//
//  ScoreAddUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/08/09.
//

import Foundation

@MainActor
public protocol ScoreAddUseCaseInterface {
    func execute(targetHitPoint: Int)
}

@MainActor
public final class ScoreAddUseCase: ScoreAddUseCaseInterface {
    private var gameStore: GameStoreInterface
    
    public init(gameStore: GameStoreInterface) {
        self.gameStore = gameStore
    }
    
    public func execute(targetHitPoint: Int) {
        gameStore.score.add(targetHitPoint: targetHitPoint)
    }
}
