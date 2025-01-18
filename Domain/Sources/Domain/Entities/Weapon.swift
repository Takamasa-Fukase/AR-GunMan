//
//  Weapon.swift
//  WeaponFiringSimulator
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

public struct Weapon {
    public let id: Int
    public let isDefault: Bool
    let spec: Spec
    let resources: Resources
    
    public struct Spec {
        let capacity: Int
        let reloadWaitingTime: TimeInterval
        let reloadType: ReloadType
        let targetHitPoint: Int
        
        public init(
            capacity: Int,
            reloadWaitingTime: TimeInterval,
            reloadType: ReloadType,
            targetHitPoint: Int
        ) {
            self.capacity = capacity
            self.reloadWaitingTime = reloadWaitingTime
            self.reloadType = reloadType
            self.targetHitPoint = targetHitPoint
        }
    }
    
    public struct Resources {
        let weaponImageName: String
        let sightImageName: String
        let sightImageColorType: ColorType
        let bulletsCountImageBaseName: String
        let appearingSound: SoundType
        let firingSound: SoundType
        let reloadingSound: SoundType
        let outOfBulletsSound: SoundType?
        let bulletHitSound: SoundType?
        
        public init(
            weaponImageName: String,
            sightImageName: String,
            sightImageColorType: ColorType,
            bulletsCountImageBaseName: String,
            appearingSound: SoundType,
            firingSound: SoundType,
            reloadingSound: SoundType,
            outOfBulletsSound: SoundType?,
            bulletHitSound: SoundType?
        ) {
            self.weaponImageName = weaponImageName
            self.sightImageName = sightImageName
            self.sightImageColorType = sightImageColorType
            self.bulletsCountImageBaseName = bulletsCountImageBaseName
            self.appearingSound = appearingSound
            self.firingSound = firingSound
            self.reloadingSound = reloadingSound
            self.outOfBulletsSound = outOfBulletsSound
            self.bulletHitSound = bulletHitSound
        }
    }
    
    public init(
        id: Int,
        isDefault: Bool,
        spec: Spec,
        resources: Resources
    ) {
        self.id = id
        self.isDefault = isDefault
        self.spec = spec
        self.resources = resources
    }
}
