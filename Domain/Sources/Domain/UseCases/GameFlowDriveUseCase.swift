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
    private var gameStore: GameStoreInterface
    private var timerTask: Task<Void, Never>?
    private let statusContinuation: AsyncStream<GameFlowStatus>.Continuation
    
    public init(
        tutorialRepository: TutorialRepositoryInterface,
        gameStore: GameStoreInterface
    ) {
        self.tutorialRepository = tutorialRepository
        self.gameStore = gameStore
        
        (statusStream, statusContinuation) = AsyncStream.makeStream()
    }
    
    public func start() {
        guard gameStore.gameFlow.status == .flowNotStarted else {
            return
        }
        updateAndHandleNextStatus(nextStatus: .checkingTutorialCompletedStatus)
    }
    
    public func pauseTimer() {
        guard gameStore.gameFlow.status == .timerStartedAndWaitingForTimerEnd else {
            return
        }
        disposeTimer()
        updateAndHandleNextStatus(nextStatus: .blocked(reason: .timerPaused))
    }
    
    public func resolveBlocked() {
        guard case .blocked(let reason) = gameStore.gameFlow.status else {
            return
        }
        switch reason {
        case .tutorialNotCompleted:
            tutorialRepository.updateTutorialCompletedFlag(isCompleted: true)
            updateAndHandleNextStatus(nextStatus: .waitingForTimerStart)

        case .timerPaused:
            updateAndHandleNextStatus(nextStatus: .timerResumedAndWaitingForTimerEnd)
        }
    }
    
    private func updateAndHandleNextStatus(nextStatus: GameFlowStatus) {
        gameStore.gameFlow.drive(to: nextStatus)
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
                    if gameStore.timeCount.isTimeUp {
                        updateAndHandleNextStatus(nextStatus: .timerEndedAndWaitingForFlowEnd)
                        disposeTimer()
                        break
                    }
                    
                    try? await Task.sleep(for: .milliseconds(GameTimeCount.updateIntervalMillisec))
                    gameStore.timeCount.decrement()
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
