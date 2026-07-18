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
}

public final class GameFlowDriveUseCase: GameFlowDriveUseCaseInterface {
    private let tutorialRepository: TutorialRepositoryInterface
    private var gameSessionRepository: GameSessionRepositoryInterface
    private var cancellables: Set<AnyCancellable> = []
    
    public init(
        gameSessionRepository: GameSessionRepositoryInterface,
        tutorialRepository: TutorialRepositoryInterface
    ) {
        self.gameSessionRepository = gameSessionRepository
        self.tutorialRepository = tutorialRepository
    }
    
    public func execute() {
        let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
        
        guard isTutorialCompleted else {
            gameSessionRepository.session.gameFlow.handle(input: .tutorialNotCompleted)
            return
        }
        
        gameSessionRepository.session.gameFlow.handle(input: .tutorialCompleted)
        
        Task {
            // 1.5秒待機
            try? await Task.sleep(for: .milliseconds(1500))
            
            gameSessionRepository.session.gameFlow.handle(input: .timerStartWaitingTimeElapsed)
            
            // TODO: 武器選択画面表示中はタイマーを一時停止したいので考慮追加する
            // タイマーループ開始
            while !Task.isCancelled {
                if gameSessionRepository.session.timeCountMillisec <= 0 {
                    gameSessionRepository.session.gameFlow.handle(input: .timerEnded)
                    break
                }
                
                // TODO: 減算する1msと待機の1msをconstで共通にしたい　両者の乖離のミスを防ぐため
                try? await Task.sleep(for: .milliseconds(1))
                
                gameSessionRepository.session.decrementTimeCountMillisec()
            }
            
            // 1.5秒待機
            try? await Task.sleep(for: .milliseconds(1500))
            
            gameSessionRepository.session.gameFlow.handle(input: .flowEndWaitingTimeElapsed)
        }
    }
}
