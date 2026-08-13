//
//  GameFlow.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/16.
//

import Foundation

public struct GameFlow {
    public private(set) var status: GameFlowStatus = .flowNotStarted
    
    public init() {}
    
    mutating func drive(to nextStatus: GameFlowStatus) {
        status = nextStatus
    }
}

public enum GameFlowStatus: Equatable {
    case flowNotStarted
    case checkingTutorialCompletedStatus
    case waitingForTimerStart
    case timerStartedAndWaitingForTimerEnd
    case timerResumedAndWaitingForTimerEnd
    case timerEndedAndWaitingForFlowEnd
    case flowEnded
    case blocked(reason: BlockedReason)
    
    public enum BlockedReason: Equatable {
        case tutorialNotCompleted
        case timerPaused
    }
    
    var isTimerRunning: Bool {
        switch self {
        case .timerStartedAndWaitingForTimerEnd, .timerResumedAndWaitingForTimerEnd:
            return true
        default:
            return false
        }
    }
}
