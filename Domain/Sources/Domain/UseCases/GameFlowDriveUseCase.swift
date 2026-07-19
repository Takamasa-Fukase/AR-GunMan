//
//  GameFlowDriveUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation

public protocol GameFlowDriveUseCaseInterface {
    var statusStream: AsyncStream<GameFlowStatus> { get }
    func start()
    func pauseTimer()
    func resolveBlocked()
}

public final class GameFlowDriveUseCase: GameFlowDriveUseCaseInterface {
    public let statusStream: AsyncStream<GameFlowStatus>
    private let tutorialRepository: TutorialRepositoryInterface
    private var gameSessionRepository: GameSessionRepositoryInterface
    private var timerTask: Task<Void, Never>?
    private var session: GameSession {
        get { return gameSessionRepository.session }
        set { gameSessionRepository.session = newValue }
    }
    private var status: GameFlowStatus {
        return session.gameFlow.status
    }
    private let statusContinuation: AsyncStream<GameFlowStatus>.Continuation
    
    public init(
        gameSessionRepository: GameSessionRepositoryInterface,
        tutorialRepository: TutorialRepositoryInterface
    ) {
        self.gameSessionRepository = gameSessionRepository
        self.tutorialRepository = tutorialRepository
        
        (statusStream, statusContinuation) = AsyncStream.makeStream()
    }
    
    public func start() {
        guard status == .flowNotStarted else {
            return
        }
        updateStatus(to: .checkingTutorialCompletedStatus)
    }
    
    public func pauseTimer() {
        guard status == .timerStartedAndWaitingForTimerEnd else {
            return
        }
        disposeTimer()
        updateStatus(to: .blocked(reason: .timerPaused))
    }
    
    public func resolveBlocked() {
        guard case .blocked(let reason) = status else {
            return
        }
        switch reason {
        case .tutorialNotCompleted:
            updateStatus(to: .waitingForTimerStart)

        case .timerPaused:
            updateStatus(to: .timerStartedAndWaitingForTimerEnd)
        }
    }
    
    private func updateStatus(to status: GameFlowStatus) {
        session.driveGameFlow(to: status)
        handleUpdatedStatus(status)
        statusContinuation.yield(status)
    }
    
    private func handleUpdatedStatus(_ status: GameFlowStatus) {
        print("usecase handleUpdatedStatus : \(status)")
        switch status {
        case .checkingTutorialCompletedStatus:
            let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
            if isTutorialCompleted {
                updateStatus(to: .waitingForTimerStart)
            } else {
                updateStatus(to: .blocked(reason: .tutorialNotCompleted))
            }
            
        case .waitingForTimerStart:
            Task {
                // 1.5秒待機
                try? await Task.sleep(for: .milliseconds(1500))
                updateStatus(to: .timerStartedAndWaitingForTimerEnd)
            }
            
        case .timerStartedAndWaitingForTimerEnd:
            timerTask = Task {
                // タイマーループ開始
                while !Task.isCancelled {
                    if session.timeCountMillisec <= 0 {
                        updateStatus(to: .timerEndedAndWaitingForFlowEnd)
                        disposeTimer()
                        break
                    }
                    
                    try? await Task.sleep(for: .milliseconds(GameSession.timerUpdateIntervalMillisec))
                    session.decrementTimeCountMillisec()
                }
            }
            
        case .timerEndedAndWaitingForFlowEnd:
            Task {
                // 1.5秒待機
                try? await Task.sleep(for: .milliseconds(1500))
                updateStatus(to: .flowEnded)
            }
            
        case .flowNotStarted, .flowEnded, .blocked:
            break
        }
    }
    
    private func disposeTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
