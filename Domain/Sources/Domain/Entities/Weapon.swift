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

public struct Weapon {
    public let id: Int
    public let isDefault: Bool
    public let spec: Spec
    public let resources: Resources
    
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
    
    public struct Spec {
        public let capacity: Int
        public let reloadWaitingTime: TimeInterval
        public let reloadType: ReloadType
        public let targetHitPoint: Int
        
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
        public let weaponImageName: String
        public let sightImageName: String
        public let sightImageColorType: ColorType
        public let bulletsCountImageBaseName: String
        public let appearingSound: SoundType
        public let firingSound: SoundType
        public let reloadingSound: SoundType
        public let outOfBulletsSound: SoundType?
        public let bulletHitSound: SoundType?
        
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
}
