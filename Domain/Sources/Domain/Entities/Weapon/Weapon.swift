//
//  Weapon.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 5/11/24.
//

import Foundation

public enum ColorType {
    case red
    case green
}

public enum ReloadType {
    case manual
    case auto
}

public protocol WeaponSpec {
    var capacity: Int { get }
    var reloadWaitingTime: TimeInterval { get }
    var reloadType: ReloadType { get }
    var targetHitPoint: Int { get }
}

public protocol WeaponResources {
    var weaponImageName: String { get }
    var sightImageName: String { get }
    var sightImageColorType: ColorType { get }
    var bulletsCountImageBaseName: String { get }
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

public protocol Weapon {
    associatedtype Spec: WeaponSpec
    associatedtype Resources: WeaponResources
    
    var id: Int { get }
    var isDefault: Bool { get }
    var spec: Spec { get }
    var resources: Resources { get }
}
