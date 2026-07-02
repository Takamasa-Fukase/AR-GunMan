//
//  WeaponResources.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/06/30.
//

import Foundation

// TODO: 直でUIColor指定すればいらなくなるかも
public enum ColorType {
    case red
    case green
}

protocol WeaponResources {
    // TODO: VMに移動後は、最初からUIImage型などに整えた状態でExtに持たせてViewを軽くしたい
    var weaponImageName: String { get }
    var sightImageName: String { get }
    // TODO: いらなくなるかも
    var sightImageColorType: ColorType { get }
    // TODO: これもいらなくなるかも？？？
    var bulletsCountImageBaseName: String { get }
}
