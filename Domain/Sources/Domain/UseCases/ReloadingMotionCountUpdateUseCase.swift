//
//  ReloadingMotionCountUpdateUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/08/09.
//

import Foundation

@MainActor
public protocol ReloadingMotionCountUpdateUseCaseInterface {
    func execute() -> ReloadingMotionDetectedCountUpdateResult
}

@MainActor
public final class ReloadingMotionCountUpdateUseCase: ReloadingMotionCountUpdateUseCaseInterface {
    private var gameStore: GameStoreInterface
    
    public init(gameStore: GameStoreInterface) {
        self.gameStore = gameStore
    }
    
    public func execute() -> ReloadingMotionDetectedCountUpdateResult {
        return gameStore.reloadingMotionDetectedCount.update()
    }
}
