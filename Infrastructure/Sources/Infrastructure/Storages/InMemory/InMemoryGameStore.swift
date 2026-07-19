//
//  InMemoryGameStore.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/07/15.
//

import Foundation
import Observation
import Data
import Domain

@Observable
public final class InMemoryGameStore: GameStoreInterface {
    @ObservationIgnored public var gameFlow = GameFlow()
    public var timeCount = GameTimeCount()
    public var score = GameScore()
    public var reloadingMotionDetectedCount = ReloadingMotionDetectedCount()
    
    public init() {}
}
