//
//  GameStore.swift
//  Presentation
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class GameStore: GameStoreInterface {
    public static let shared = GameStore()

    @ObservationIgnored
    public var gameFlow = GameFlow()
    
    public var timeCount = GameTimeCount()
    public var score = GameScore()
    public var reloadingMotionDetectedCount = ReloadingMotionDetectedCount()
    
    private init() {}
    
    func reset() {
        gameFlow = .init()
        timeCount = .init()
        score = .init()
        reloadingMotionDetectedCount = .init()
    }
}
