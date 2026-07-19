//
//  GameFlowDriveUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation

@MainActor
public protocol GameFlowDriveUseCaseInterface {
    var statusStream: AsyncStream<GameFlowStatus> { get }
    func start()
    func pauseTimer()
    func resolveBlocked()
}

@MainActor
public final class GameFlowDriveUseCase: GameFlowDriveUseCaseInterface {
    public let statusStream: AsyncStream<GameFlowStatus>
    
    private let tutorialRepository: TutorialRepositoryInterface
    private var gameRepository: GameRepositoryInterface
    private var timerTask: Task<Void, Never>?
    private let statusContinuation: AsyncStream<GameFlowStatus>.Continuation
    
    public init(
        gameRepository: GameRepositoryInterface,
        tutorialRepository: TutorialRepositoryInterface
    ) {
        self.gameRepository = gameRepository
        self.tutorialRepository = tutorialRepository
        
        (statusStream, statusContinuation) = AsyncStream.makeStream()
    }
    
    public func start() {
        guard gameRepository.gameFlowStatus == .flowNotStarted else {
            return
        }
        updateAndHandleNextStatus(nextStatus: .checkingTutorialCompletedStatus)
    }
    
    public func pauseTimer() {
        guard gameRepository.gameFlowStatus == .timerStartedAndWaitingForTimerEnd else {
            return
        }
        disposeTimer()
        updateAndHandleNextStatus(nextStatus: .blocked(reason: .timerPaused))
    }
    
    public func resolveBlocked() {
        guard case .blocked(let reason) = gameRepository.gameFlowStatus else {
            return
        }
        switch reason {
        case .tutorialNotCompleted:
            updateAndHandleNextStatus(nextStatus: .waitingForTimerStart)

        case .timerPaused:
            updateAndHandleNextStatus(nextStatus: .timerResumedAndWaitingForTimerEnd)
        }
    }
    
    private func updateAndHandleNextStatus(nextStatus: GameFlowStatus) {
        gameRepository.driveGameFlow(to: nextStatus)
        handleUpdatedStatus(nextStatus)
        statusContinuation.yield(nextStatus)
    }
    
    private func handleUpdatedStatus(_ status: GameFlowStatus) {
        switch status {
        case .checkingTutorialCompletedStatus:
            let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
            if isTutorialCompleted {
                updateAndHandleNextStatus(nextStatus: .waitingForTimerStart)
            } else {
                updateAndHandleNextStatus(nextStatus: .blocked(reason: .tutorialNotCompleted))
            }
            
        case .waitingForTimerStart:
            Task {
                // 1.5秒待機
                try? await Task.sleep(for: .milliseconds(1500))
                updateAndHandleNextStatus(nextStatus: .timerStartedAndWaitingForTimerEnd)
            }
            
        case .timerStartedAndWaitingForTimerEnd, .timerResumedAndWaitingForTimerEnd:
            timerTask = Task {
                // タイマーループ開始
                while !Task.isCancelled {
                    if gameRepository.isTimeUp {
                        updateAndHandleNextStatus(nextStatus: .timerEndedAndWaitingForFlowEnd)
                        disposeTimer()
                        break
                    }
                    
                    try? await Task.sleep(for: .milliseconds(GameTimeCount.updateIntervalMillisec))
                    gameRepository.decrementTimeCount()
                }
            }
            
        case .timerEndedAndWaitingForFlowEnd:
            Task {
                // 1.5秒待機
                try? await Task.sleep(for: .milliseconds(1500))
                updateAndHandleNextStatus(nextStatus: .flowEnded)
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
