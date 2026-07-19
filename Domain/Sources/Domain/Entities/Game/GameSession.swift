//
//  GameSession.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public struct GameSession {
    public private(set) var gameFlow = GameFlow()
    public private(set) var timeCount = GameTimeCount()
    public private(set) var score = GameScore()
    public private(set) var reloadingMotionDetectedCount = ReloadingMotionDetectedCount()
    
    public init() {}
    
    mutating func driveGameFlow(to nextStatus: GameFlowStatus) {
        gameFlow.drive(to: nextStatus)
    }
    
    mutating func decrementTimeCount() {
        timeCount.decrement()
    }
    
    mutating func addScore(targetHitPoint: Int) {
        score.add(targetHitPoint: targetHitPoint)
    }
    
    mutating func updateReloadingMotionDetectedCount() -> ReloadingMotionDetectedCount.Result {
        return reloadingMotionDetectedCount.update()
    }
}
