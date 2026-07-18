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
    private var session: GameSession {
        get { return gameSessionRepository.session }
        set { gameSessionRepository.session = newValue }
    }
    private var status: GameFlowStatus {
        return session.gameFlow.status
    }
    
    public init(
        gameSessionRepository: GameSessionRepositoryInterface,
        tutorialRepository: TutorialRepositoryInterface
    ) {
        self.gameSessionRepository = gameSessionRepository
        self.tutorialRepository = tutorialRepository
        
        Task {
            for await status in session.gameFlow.statusStream {
                handleStatus(status)
            }
        }
    }
    
    public func start() {
        guard status == .flowNotStarted else {
            return
        }
        session.driveGameFlow(to: .checkingTutorialCompletedStatus)
    }
    
    public func pauseTimer() {
        guard status == .timerStartedAndWaitingForTimerEnd else {
            return
        }
        disposeTimer()
        session.driveGameFlow(to: .blocked(reason: .timerPaused))
    }
    
    public func resolveBlocked() {
        guard case .blocked(let reason) = status else {
            return
        }
        switch reason {
        case .tutorialNotCompleted:
            session.driveGameFlow(to: .waitingForTimerStart)

        case .timerPaused:
            session.driveGameFlow(to: .timerStartedAndWaitingForTimerEnd)
        }
    }
    
    private func handleStatus(_ status: GameFlowStatus) {
        switch status {
        case .checkingTutorialCompletedStatus:
            let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
            if isTutorialCompleted {
                session.driveGameFlow(to: .waitingForTimerStart)
            } else {
                session.driveGameFlow(to: .blocked(reason: .tutorialNotCompleted))
            }
            
        case .waitingForTimerStart:
            Task {
                // 1.5秒待機
                try? await Task.sleep(for: .milliseconds(1500))
                session.driveGameFlow(to: .timerStartedAndWaitingForTimerEnd)
            }
            
        case .timerStartedAndWaitingForTimerEnd:
            timerTask = Task {
                // タイマーループ開始
                while !Task.isCancelled {
                    if session.timeCountMillisec <= 0 {
                        session.driveGameFlow(to: .timerEndedAndWaitingForFlowEnd)
                        disposeTimer()
                        break
                    }
                    
                    // TODO: 減算する1msと待機の1msをconstで共通にしたい　両者の乖離のミスを防ぐため
                    try? await Task.sleep(for: .milliseconds(1))
                    session.decrementTimeCountMillisec()
                }
            }
            
        case .timerEndedAndWaitingForFlowEnd:
            Task {
                // 1.5秒待機
                try? await Task.sleep(for: .milliseconds(1500))
                session.driveGameFlow(to: .flowEnded)
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
