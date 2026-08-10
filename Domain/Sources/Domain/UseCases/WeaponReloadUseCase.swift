//
//  WeaponReloadUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

@MainActor
public protocol WeaponReloadUseCaseInterface {
    func execute() -> WeaponReloadStartResult
}

extension WeaponReloadUseCaseInterface {
    func stopCurrentReloadIfExists() {}
}

@MainActor
public final class WeaponReloadUseCase: WeaponReloadUseCaseInterface {
    private var weaponStore: WeaponStoreInterface
    private var reloadTask: Task<Void, Never>?

    public init(weaponStore: WeaponStoreInterface) {
        self.weaponStore = weaponStore
    }
    
    public func execute() -> WeaponReloadStartResult {
        let startResult = weaponStore.weapon.startReload()

        reloadTask = Task {
            try? await Task.sleep(
                for: .milliseconds(
                    weaponStore.weapon.currentType.reloadWaitingTimeMillisec
                )
            )
            
            
            weaponStore.weapon.finishReload()
        }
        
        return startResult
    }
    
    func stopCurrentReloadIfExists() {
        reloadTask?.cancel()
        reloadTask = nil
    }
}
