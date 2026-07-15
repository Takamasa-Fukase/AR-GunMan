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
    private var gameSessionRepository: GameSessionRepositoryInterface
    
    public init(
        weaponRepository: WeaponRepositoryInterface,
        gameSessionRepository: GameSessionRepositoryInterface
    ) {
        self.weaponRepository = weaponRepository
        self.gameSessionRepository = gameSessionRepository
    }
    
    public func execute() {
        let targetHitPoint = weaponRepository.weapon.currentType.weaponInfo.spec.targetHitPoint
        gameSessionRepository.session.addScore(targetHitPoint: targetHitPoint)
    }
}
