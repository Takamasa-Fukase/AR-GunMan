//
//  GameRepositoryInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation

public protocol GameRepositoryInterface {
    var gameFlowStatus: GameFlowStatus { get }
    var timeCountMillisec: Int { get }
    var isTimeUp: Bool { get }
    var score: Double { get }
    func driveGameFlow(to nextStatus: GameFlowStatus)
    func decrementTimeCount()
    func addScore(targetHitPoint: Int)
    func updateReloadingMotionDetectedCount() -> ReloadingMotionDetectedCountUpdateResult
}
