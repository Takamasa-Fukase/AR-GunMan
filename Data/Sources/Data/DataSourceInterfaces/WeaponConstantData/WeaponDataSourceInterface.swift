//
//  WeaponDataSourceInterface.swift
//  Data
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation
import Domain

public protocol WeaponDataSourceInterface {
    var list: [any Weapon] { get }
}
