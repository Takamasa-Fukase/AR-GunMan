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
    private var weaponRepository: WeaponRepositoryInterface
    private let gameSession: GameSession
    
    public init(
        weaponRepository: WeaponRepositoryInterface,
        gameSession: GameSession
    ) {
        self.weaponRepository = weaponRepository
        self.gameSession = gameSession
    }
    
    public func execute() {
        let targetHitPoint = weaponRepository.weapon.currentType.weaponInfo.spec.targetHitPoint
        gameSession.score.add(targetHitPoint: targetHitPoint)
    }
}
