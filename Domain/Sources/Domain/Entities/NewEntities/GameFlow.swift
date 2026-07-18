//
//  GameFlow.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/16.
//

import Foundation

public struct GameFlow {
    public private(set) var status: GameFlowStatus = .flowNotStarted {
        didSet {
            statusContinuation.yield(status)
        }
    }
    public let statusStream: AsyncStream<GameFlowStatus>
    
    private let statusContinuation: AsyncStream<GameFlowStatus>.Continuation
    
    init() {
        (statusStream, statusContinuation) = AsyncStream.makeStream()
    }
    
    mutating func drive() {
        if let currentIndex = GameFlowStatus.allCases.firstIndex(of: status),
           currentIndex < GameFlowStatus.allCases.count - 1 {
            status = GameFlowStatus.allCases[currentIndex + 1]
        }
    }
}

public enum GameFlowStatus: CaseIterable {
    case flowNotStarted
    case waitingForTutorialComplete
    case waitingForTimerStart
    case timerStartedAndWaitingForTimerEnd
    case timerEndedAndWaitingForFlowEnd
    case flowEnded
}
