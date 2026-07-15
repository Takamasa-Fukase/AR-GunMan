//
//  GameSession.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public struct GameSession {
    public private(set) var timeCountMillisec: Int
    public private(set) var score: GameScore
    public private(set) var reloadingMotionDetectedCount: Int
    
    public init() {
        timeCountMillisec = 30000
        score = .init()
        reloadingMotionDetectedCount = 0
    }
    
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
}

public enum ReloadingMotionDetectedCountCheckResult {
    case notExceededLimit
    case exceededLimit
}
