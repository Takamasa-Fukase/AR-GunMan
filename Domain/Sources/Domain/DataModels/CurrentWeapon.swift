//
//  CurrentWeaponData.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 14/11/24.
//

import Foundation

public struct CurrentWeapon {
    public let weapon: Weapon
    public var state: State
    
    public init(
        weapon: Weapon,
        state: State
    ) {
        self.weapon = weapon
        self.state = state
    }
    
    public struct State {
        public var bulletsCount: Int
        public var isReloading: Bool
        
        public init(
            bulletsCount: Int,
            isReloading: Bool
        ) {
            self.bulletsCount = bulletsCount
            self.isReloading = isReloading
        }
    }
    
    public func bulletsCountImageName() -> String {
        return weapon.resources.bulletsCountImageBaseName + String(state.bulletsCount)
    }
}
