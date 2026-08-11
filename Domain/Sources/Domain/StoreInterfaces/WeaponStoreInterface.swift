//
//  WeaponStoreInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/10.
//

import Foundation

@MainActor
public protocol WeaponStoreInterface: AnyObject {
    var weapon: Weapon { get set }
    func reset()
}
