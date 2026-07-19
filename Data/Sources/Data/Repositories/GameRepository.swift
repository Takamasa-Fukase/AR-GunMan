//
//  GameRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation
import Domain

public final class GameRepository: GameRepositoryInterface {
    private var gameStore: GameStoreInterface
    
    public var gameFlowStatus: GameFlowStatus {
        return gameStore.gameFlow.status
    }
    
    public var timeCountMillisec: Int {
        return gameStore.timeCount.countMillisec
    }
    
    public var isTimeUp: Bool {
        return gameStore.timeCount.isTimeUp
    }
    
    public var score: Double {
        return gameStore.score.value
    }
    
    public init(gameStore: GameStoreInterface) {
        self.gameStore = gameStore
    }
    
    public func driveGameFlow(to nextStatus: GameFlowStatus) {
        gameStore.gameFlow.drive(to: nextStatus)
    }
    
    public func decrementTimeCount() {
        gameStore.timeCount.decrement()
    }
    
    public func addScore(targetHitPoint: Int) {
        gameStore.score.add(targetHitPoint: targetHitPoint)
    }
    
    public func updateReloadingMotionDetectedCount() -> ReloadingMotionDetectedCountUpdateResult {
        return gameStore.reloadingMotionDetectedCount.update()
    }
}
