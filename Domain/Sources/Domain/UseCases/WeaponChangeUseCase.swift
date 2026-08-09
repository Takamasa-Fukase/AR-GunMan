//
//  WeaponChangeUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

@MainActor
public protocol WeaponChangeUseCaseInterface {
    func execute(newType: WeaponType)
}

@MainActor
public final class WeaponChangeUseCase: WeaponChangeUseCaseInterface {
    private var weaponStore: WeaponStoreInterface
    private let weaponReloadUseCase: WeaponReloadUseCaseInterface

    public init(
        weaponStore: WeaponStoreInterface,
        weaponReloadUseCase: WeaponReloadUseCaseInterface
    ) {
        self.weaponStore = weaponStore
        self.weaponReloadUseCase = weaponReloadUseCase
    }
    
    public func execute(newType: WeaponType) {
        // 既存のリロードをキャンセルする
        weaponReloadUseCase.stopCurrentReloadIfExists()
        weaponStore.weapon.change(to: newType)
    }
}
