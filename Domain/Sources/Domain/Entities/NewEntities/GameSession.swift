//
//  GameSession.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public final class GameSession {
    var timeCountMillisec: Int
    var score: GameScore
    var reloadingMotionDetectedCount: Int
    
    public init() {
        timeCountMillisec = 30000
        score = .init()
        reloadingMotionDetectedCount = 0
    }
}
