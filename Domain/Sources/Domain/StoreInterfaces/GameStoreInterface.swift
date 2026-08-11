//
//  GameStoreInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/10.
//

import Foundation

@MainActor
public protocol GameStoreInterface: AnyObject {
    var gameFlow: GameFlow { get set }
    var timeCount: GameTimeCount { get set }
    var score: GameScore { get set }
    var reloadingMotionDetectedCount: ReloadingMotionDetectedCount { get set }
    func reset()
}
