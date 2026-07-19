//
//  ReloadingMotionDetectedCountHandleUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation

public protocol ReloadingMotionDetectedCountHandleUseCaseInterface {
    func execute() -> ReloadingMotionDetectedCount.Result
}

public final class ReloadingMotionDetectedCountHandleUseCase: ReloadingMotionDetectedCountHandleUseCaseInterface {
    private var gameSessionRepository: GameSessionRepositoryInterface
    
    public init(gameSessionRepository: GameSessionRepositoryInterface) {
        self.gameSessionRepository = gameSessionRepository
    }
    
    public func execute() -> ReloadingMotionDetectedCount.Result {
        return gameSessionRepository.session.updateReloadingMotionDetectedCount()
    }
}
