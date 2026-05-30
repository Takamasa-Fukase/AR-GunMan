//
//  Bazooka.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation

public struct Bazooka: Weapon {
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
    
    public struct Spec: WeaponSpec {
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
    
    public struct Resources: WeaponResources {
        public let weaponImageName: String
        public let sightImageName: String
        public let sightImageColorType: ColorType
        public let bulletsCountImageBaseName: String
        public let appearingSound: SoundType
        public let firingSound: SoundType
        public let reloadingSound: SoundType
        public let bulletHitSound: SoundType?
        
        public init(
            weaponImageName: String,
            sightImageName: String,
            sightImageColorType: ColorType,
            bulletsCountImageBaseName: String,
            appearingSound: SoundType,
            firingSound: SoundType,
            reloadingSound: SoundType,
            bulletHitSound: SoundType?
        ) {
            self.weaponImageName = weaponImageName
            self.sightImageName = sightImageName
            self.sightImageColorType = sightImageColorType
            self.bulletsCountImageBaseName = bulletsCountImageBaseName
            self.appearingSound = appearingSound
            self.firingSound = firingSound
            self.reloadingSound = reloadingSound
            self.bulletHitSound = bulletHitSound
        }
    }
}
