//
//  WeaponSoundResources.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/06/30.
//

import Foundation
import DeviceInterface

protocol WeaponSoundResources {
    var appearingSound: SoundType { get }
    var firingSound: SoundType { get }
    var reloadingSound: SoundType { get }
    var outOfBulletsSound: SoundType? { get }
    var bulletHitSound: SoundType? { get }
}

extension WeaponSoundResources {
    var outOfBulletsSound: SoundType? { return nil }
    var bulletHitSound: SoundType? { return nil }
}

struct BazookaSoundResources: WeaponSoundResources {
    public let appearingSound: SoundType
    public let firingSound: SoundType
    public let reloadingSound: SoundType
    public let bulletHitSound: SoundType?
}

struct PistolSoundResources: WeaponSoundResources {
    public let appearingSound: SoundType
    public let firingSound: SoundType
    public let reloadingSound: SoundType
    public let outOfBulletsSound: SoundType?
}
