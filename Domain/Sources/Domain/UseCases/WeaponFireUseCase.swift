//
//  WeaponFireUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

@MainActor
public protocol WeaponFireUseCaseInterface {
    func execute() -> WeaponFireResult
}

@MainActor
public final class WeaponFireUseCase: WeaponFireUseCaseInterface {
    private var weaponStore: WeaponStoreInterface
    private let weaponReloadUseCase: WeaponReloadUseCaseInterface

    public init(
        weaponStore: WeaponStoreInterface,
        weaponReloadUseCase: WeaponReloadUseCaseInterface
    ) {
        self.weaponStore = weaponStore
        self.weaponReloadUseCase = weaponReloadUseCase
    }
    
    public func execute() -> WeaponFireResult {
        let result = weaponStore.weapon.fire()
        if result == .success && weaponStore.weapon.currentType.reloadType == .auto {
            // リロードを自動的に実行
            weaponReloadUseCase.execute()
        }
        return result
    }
}
