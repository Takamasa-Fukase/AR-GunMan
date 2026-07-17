//
//  GameFlowDriveUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation

public protocol GameFlowDriveUseCaseInterface {
    func execute()
}

public final class GameFlowDriveUseCase: GameFlowDriveUseCaseInterface {
    private var gameSessionRepository: GameSessionRepositoryInterface
    
    public init(gameSessionRepository: GameSessionRepositoryInterface) {
        self.gameSessionRepository = gameSessionRepository
    }
    
    public func execute() {
        gameSessionRepository.session.gameFlow.handle(input: .flowStarted)
        
        
        
        /*
         次にチュートリアルrepo経由で取得する
         
         
         */
    }
}
