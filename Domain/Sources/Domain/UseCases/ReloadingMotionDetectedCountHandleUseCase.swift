//
//  ReloadingMotionDetectedCountHandleUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation

public protocol ReloadingMotionDetectedCountHandleUseCaseInterface {
    func execute() -> ReloadingMotionDetectedCountCheckResult
}

public final class ReloadingMotionDetectedCountHandleUseCase: ReloadingMotionDetectedCountHandleUseCaseInterface {
    private var gameSessionRepository: GameSessionRepositoryInterface
    
    public init(gameSessionRepository: GameSessionRepositoryInterface) {
        self.gameSessionRepository = gameSessionRepository
    }
    
    public func execute() -> ReloadingMotionDetectedCountCheckResult {
        gameSessionRepository.session.incrementReloadingMotionDetectedCount()
        return gameSessionRepository.session.checkExceedsReloadingMotionDetectedCountLimit()
    }
}
