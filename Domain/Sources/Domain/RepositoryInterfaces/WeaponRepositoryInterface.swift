//
//  WeaponRepositoryInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 6/11/24.
//

import Foundation

@MainActor
public protocol WeaponRepositoryInterface {
    var weaponType: WeaponType { get }
    var bulletsCount: Int { get }
    func fire() -> WeaponFireResult
    func startReload() -> WeaponReloadStartResult
    func finishReload()
    func change(to newType: WeaponType)
}
