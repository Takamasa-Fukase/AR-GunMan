//
//  GameSession.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public struct GameSession {
    public private(set) var timeCountMillisec: Int = 30000
    public private(set) var score = GameScore()
    public private(set) var reloadingMotionDetectedCount: Int = 0
    public let gameFlow = GameFlow()
    
    public init() {}
    
    mutating func addScore(targetHitPoint: Int) {
        score.add(targetHitPoint: targetHitPoint)
    }
    
    mutating func incrementReloadingMotionDetectedCount() {
        reloadingMotionDetectedCount += 1
    }
    
    func checkExceedsReloadingMotionDetectedCountLimit() -> ReloadingMotionDetectedCountCheckResult {
        if reloadingMotionDetectedCount == 20 {
            return .exceededLimit
        } else {
            return .notExceededLimit
        }
    }
    
    func dispatchGameFlowInputEvent(input: GameFlowInputEvent) {
        gameFlow.handle(input: input)
    }
}

public enum ReloadingMotionDetectedCountCheckResult {
    case notExceededLimit
    case exceededLimit
}
