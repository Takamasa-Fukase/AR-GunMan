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
        
//        tutorialRepository
//            .isTutorialCompletedPublisher
//            .sink { [weak self] isCompleted in
//                
//                
//                
//            }.store(in: &cancellables)
    }
    
    public func execute() {
        let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
        
        guard isTutorialCompleted else {
            gameSessionRepository.session.gameFlow.handle(input: .tutorialNotCompleted)
            return
        }
        
        gameSessionRepository.session.gameFlow.handle(input: .tutorialCompleted)
        
        // TODO: 1500ms遅延
        
        gameSessionRepository.session.gameFlow.handle(input: .timerStartWaitingTimeElapsed)
        
        // TODO: timerCreate & start
        
        
    }
}
