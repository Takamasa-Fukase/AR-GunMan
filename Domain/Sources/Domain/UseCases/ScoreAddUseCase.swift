//
//  ScoreAddUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/06.
//

import Foundation

public protocol ScoreAddUseCaseInterface {
    func execute()
}

public final class ScoreAddUseCase: ScoreAddUseCaseInterface {
    private let weapon: Weapon
    private let gameSession: GameSession

    public init(
        weapon: Weapon,
        gameSession: GameSession
    ) {
        self.weaponSession = weaponSession
        self.gameSession = gameSession
    }
    
    public func execute() {
        let targetHitPoint = weapon.currentType.weaponInfo.spec.targetHitPoint
        gameSession.score.add(targetHitPoint: targetHitPoint)
    }
}
