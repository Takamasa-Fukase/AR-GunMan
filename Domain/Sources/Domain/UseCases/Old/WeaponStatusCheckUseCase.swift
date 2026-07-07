//
//  WeaponStatusCheckUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 14/11/24.
//

import Foundation

public protocol WeaponStatusCheckUseCaseInterface {
    func checkCanFire(bulletsCount: Int,
                      isReloading: Bool) -> Bool
    func checkCanReload(bulletsCount: Int,
                        isReloading: Bool) -> Bool
    func checkNeedsAutoReload(bulletsCount: Int,
                              isReloading: Bool,
                              reloadType: ReloadType) -> Bool
}

public final class WeaponStatusCheckUseCase: WeaponStatusCheckUseCaseInterface {
    public init() {}
    
    public func checkCanFire(bulletsCount: Int, isReloading: Bool) -> Bool {
        if isReloading { return false }
        if bulletsCount > 0 {
            return true
        }else {
            return false
        }
    }
    
    public func checkCanReload(bulletsCount: Int, isReloading: Bool) -> Bool {
        if isReloading { return false }
        if bulletsCount <= 0 {
            return true
        }else {
            return false
        }
    }
    
    public func checkNeedsAutoReload(bulletsCount: Int, isReloading: Bool, reloadType: ReloadType) -> Bool {
        if isReloading { return false }
        if bulletsCount == 0 && reloadType == .auto {
            return true
        }else {
            return false
        }
    }
}
