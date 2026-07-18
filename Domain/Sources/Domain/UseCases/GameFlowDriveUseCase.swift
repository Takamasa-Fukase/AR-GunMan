//
//  GameFlowDriveUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation
import Combine

public protocol GameFlowDriveUseCaseInterface {
    func start()
    func pauseTimer()
    func resolveBlocked()
}

public final class GameFlowDriveUseCase: GameFlowDriveUseCaseInterface {
    private let tutorialRepository: TutorialRepositoryInterface
    private var gameSessionRepository: GameSessionRepositoryInterface
    private var cancellables: Set<AnyCancellable> = []
    private var timerTask: Task<Void, Never>?
//    private var gameFlow: GameFlow {
//        return gameSessionRepository.session.gameFlow
//    }
//    private var status: GameFlowStatus {
//        return gameFlow.status
//    }
    
    public init(
        gameSessionRepository: GameSessionRepositoryInterface,
        tutorialRepository: TutorialRepositoryInterface
    ) {
        self.gameSessionRepository = gameSessionRepository
        self.tutorialRepository = tutorialRepository
        
        Task {
            for await status in gameSessionRepository.session.gameFlow.statusStream {
                handleStatus(status)
            }
        }
    }
    
    public func start() {
        guard gameSessionRepository.session.gameFlow.status == .flowNotStarted else {
            return
        }
        gameSessionRepository.session.driveGameFlow(to: .checkingTutorialCompletedStatus)
    }
    
    public func pauseTimer() {
        guard gameSessionRepository.session.gameFlow.status == .timerStartedAndWaitingForTimerEnd else {
            return
        }
        disposeTimer()
        gameSessionRepository.session.driveGameFlow(to: .blocked(reason: .timerPaused))
    }
    
    public func resolveBlocked() {
        guard case .blocked(let reason) = gameSessionRepository.session.gameFlow.status else {
            return
        }
        switch reason {
        case .tutorialNotCompleted:
            gameSessionRepository.session.driveGameFlow(to: .waitingForTimerStart)

        case .timerPaused:
            gameSessionRepository.session.driveGameFlow(to: .timerStartedAndWaitingForTimerEnd)
        }
    }
    
    private func handleStatus(_ status: GameFlowStatus) {
        switch status {
        case .flowNotStarted:
            break
            
        case .checkingTutorialCompletedStatus:
            let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
            if isTutorialCompleted {
                gameSessionRepository.session.driveGameFlow(to: .waitingForTimerStart)
            } else {
                gameSessionRepository.session.driveGameFlow(to: .blocked(reason: .tutorialNotCompleted))
            }
            
        case .waitingForTimerStart:
            Task {
                // 1.5秒待機
                try? await Task.sleep(for: .milliseconds(1500))
                gameSessionRepository.session.driveGameFlow(to: .timerStartedAndWaitingForTimerEnd)
            }
            
        case .timerStartedAndWaitingForTimerEnd:
            timerTask = Task {
                // タイマーループ開始
                while !Task.isCancelled {
                    if gameSessionRepository.session.timeCountMillisec <= 0 {
                        gameSessionRepository.session.driveGameFlow(to: .timerEndedAndWaitingForFlowEnd)
                        disposeTimer()
                        break
                    }
                    
                    // TODO: 減算する1msと待機の1msをconstで共通にしたい　両者の乖離のミスを防ぐため
                    try? await Task.sleep(for: .milliseconds(1))
                    gameSessionRepository.session.decrementTimeCountMillisec()
                }
            }
            
        case .timerEndedAndWaitingForFlowEnd:
            Task {
                // 1.5秒待機
                try? await Task.sleep(for: .milliseconds(1500))
                gameSessionRepository.session.driveGameFlow(to: .flowEnded)
            }
            
        case .flowEnded:
            break
            
        case .blocked:
            break
        }
    }
    
    private func disposeTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
