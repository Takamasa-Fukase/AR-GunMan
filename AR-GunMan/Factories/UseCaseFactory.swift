//
//  UseCaseFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/11/24.
//

import Foundation
import Domain

final class UseCaseFactory {
    static func create() -> GameTimerCreateUseCaseInterface {
        return GameTimerCreateUseCase()
    }
    
    static func create() -> WeaponResourceGetUseCaseInterface {
        return WeaponResourceGetUseCase(weaponRepository: RepositoryFactory.create())
    }
    
    static func create() -> WeaponStatusCheckUseCaseInterface {
        return WeaponStatusCheckUseCase()
    }
    
    static func create() -> WeaponActionExecuteUseCaseInterface {
        return WeaponActionExecuteUseCase(weaponStatusCheckUseCase: create())
    }
}
