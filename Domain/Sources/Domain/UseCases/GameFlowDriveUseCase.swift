//
//  GameFlowDriveUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation
import Combine

public protocol GameFlowDriveUseCaseInterface {
    func execute()
    func pause()
    func resume()
}

public final class GameFlowDriveUseCase: GameFlowDriveUseCaseInterface {
    private let tutorialRepository: TutorialRepositoryInterface
    private var gameSessionRepository: GameSessionRepositoryInterface
    private var cancellables: Set<AnyCancellable> = []
    private var timerTask: Task<Void, Never>?
    
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
    
    public func execute() {
        guard gameSessionRepository.session.gameFlow.status == .flowNotStarted else {
            return
        }
        handleStatus(gameSessionRepository.session.gameFlow.status)
    }
    
    public func pause() {
        guard gameSessionRepository.session.gameFlow.status == .timerStartedAndWaitingForTimerEnd else {
            return
        }
        disposeTimer()
    }
    
    public func resume() {
        switch gameSessionRepository.session.gameFlow.status {
        case .waitingForTutorialComplete, .timerStartedAndWaitingForTimerEnd:
            handleStatus(gameSessionRepository.session.gameFlow.status)
        default:
            break
        }
    }
    
    private func handleStatus(_ status: GameFlowStatus) {
        switch status {
        case .flowNotStarted:
            gameSessionRepository.session.driveGameFlow()
            
        case .waitingForTutorialComplete:
            let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
            guard isTutorialCompleted else {
                return
            }
            gameSessionRepository.session.driveGameFlow()
            
        case .waitingForTimerStart:
            Task {
                // 1.5秒待機
                try? await Task.sleep(for: .milliseconds(1500))
                gameSessionRepository.session.driveGameFlow()
            }
            
        case .timerStartedAndWaitingForTimerEnd:
            timerTask = Task {
                // タイマーループ開始
                while !Task.isCancelled {
                    if gameSessionRepository.session.timeCountMillisec <= 0 {
                        gameSessionRepository.session.driveGameFlow()
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
                gameSessionRepository.session.driveGameFlow()
            }
            
        case .flowEnded:
            break
        }
    }
    
    private func disposeTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
