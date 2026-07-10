//
//  WeaponReloadUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public protocol WeaponReloadUseCaseInterface {
    func execute() -> WeaponReloadStartResult
}

public final class WeaponReloadUseCase: WeaponReloadUseCaseInterface {
    private var weaponRepository: WeaponRepositoryInterface

    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
    }
    
    public func execute() -> WeaponReloadStartResult {
        let startResult = weaponRepository.weapon.startReload()
        let reloadWaitingTimeMillisec = weaponRepository.weapon.currentType.weaponInfo.spec.reloadWaitingTimeMillisec
        
        print("WeaponReloadUseCase started")
        
        Task {
            try? await Task.sleep(for: .milliseconds(reloadWaitingTimeMillisec))
            self.weaponRepository.weapon.finishReload()
            
            print("WeaponReloadUseCase finished")
        }
        return startResult
    }
}
