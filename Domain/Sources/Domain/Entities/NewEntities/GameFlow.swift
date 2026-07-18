//
//  GameFlow.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/16.
//

import Foundation

public struct GameFlow {
    public let statusStream: AsyncStream<GameFlowStatus>
    
    private let continuation: AsyncStream<GameFlowStatus>.Continuation
    
    init() {
        (statusStream, continuation) = AsyncStream<GameFlowStatus>.makeStream()
    }
    
    func handle(input: GameFlowInputEvent) {
        switch input {
        case .tutorialNotCompleted:
            continuation.yield(.waitingForTutorialComplete)
            
        case .tutorialCompleted:
            continuation.yield(.waitingForTimerStart)
            
        case .timerStartWaitingTimeElapsed:
            continuation.yield(.timerStartedAndWaitingForTimerEnd)
            
        case .timerEnded:
            continuation.yield(.timerEndedAndWaitingForFlowEnd)

        case .flowEndWaitingTimeElapsed:
            continuation.yield(.flowEnded)
        }
    }
}

enum GameFlowInputEvent {
    case tutorialNotCompleted
    case tutorialCompleted
    case timerStartWaitingTimeElapsed
    case timerEnded
    case flowEndWaitingTimeElapsed
}

public enum GameFlowStatus {
    case waitingForTutorialComplete
    case waitingForTimerStart
    case timerStartedAndWaitingForTimerEnd
    case timerEndedAndWaitingForFlowEnd
    case flowEnded
}
