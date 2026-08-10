//
//  WeaponStore.swift
//  Presentation
//
//  Created by ウルトラ深瀬 on 2026/07/10.
//

import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class WeaponStore: WeaponStoreInterface {
    public static let shared = WeaponStore()
    
    public var weapon = Weapon()
    
    private init() {}
    
    func reset() {
        weapon = .init()
    }
}
