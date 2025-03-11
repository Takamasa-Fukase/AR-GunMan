//
//  ProdFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/3/25.
//

import Data
import Domain

final class ProdFactory: FactoryInterface {
    // MARK: Repositories
    static func create() -> WeaponRepositoryInterface {
        return WeaponRepository()
    }
    
    static func create() -> TutorialRepositoryInterface {
        return TutorialRepository()
    }
    
    static func create() -> PermissionRepositoryInterface {
        return PermissionRepository()
    }
    
    static func create() -> RankingRepositoryInterface {
        return RankingRepository()
    }
    
    // MARK: UseCases
    static func create() -> GameTimerCreateUseCaseInterface {
        return GameTimerCreateUseCase()
    }
    
    static func create() -> RankingUseCaseInterface {
        return RankingUseCase(rankingRepository: create())
    }
    
    static func create() -> WeaponActionExecuteUseCaseInterface {
        return WeaponActionExecuteUseCase(weaponStatusCheckUseCase: create())
    }
    
    static func create() -> WeaponResourceGetUseCaseInterface {
        return WeaponResourceGetUseCase(weaponRepository: create())
    }
    
    static func create() -> WeaponStatusCheckUseCaseInterface {
        return WeaponStatusCheckUseCase()
    }
}
