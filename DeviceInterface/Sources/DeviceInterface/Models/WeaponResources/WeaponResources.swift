//
//  WeaponResources.swift
//  DeviceInterface
//
//  Created by ウルトラ深瀬 on 2026/06/30.
//

import Foundation

public protocol WeaponResources {
    var appearingSound: SoundType { get }
    var firingSound: SoundType { get }
    var reloadingSound: SoundType { get }
    var outOfBulletsSound: SoundType? { get }
    var bulletHitSound: SoundType? { get }
}

public extension WeaponResources {
    var outOfBulletsSound: SoundType? { return nil }
    var bulletHitSound: SoundType? { return nil }
}
