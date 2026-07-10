//
//  InMemoryWeaponStore.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/07/10.
//

import Foundation
import Observation
import Data
import Domain

@Observable
public final class InMemoryWeaponStore: InMemoryWeaponStoreInterface {
    public init() {}
    
    var weapon = Weapon()
}
