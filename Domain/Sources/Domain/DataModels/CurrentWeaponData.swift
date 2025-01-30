//
//  CurrentWeaponData.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 14/11/24.
//

import Foundation

public struct CurrentWeaponData {
    public let id: Int
    public let spec: Spec
    public let resources: Resources
    public var state: State
    
    public init(
        id: Int,
        spec: Spec,
        resources: Resources,
        state: State
    ) {
        self.id = id
        self.spec = spec
        self.resources = resources
        self.state = state
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
    
    public struct State {
        public var bulletsCount: Int
        public var isReloading: Bool
        
        public init(
            bulletsCount: Int,
            isReloading: Bool
        ) {
            self.bulletsCount = bulletsCount
            self.isReloading = isReloading
        }
    }
    
    public func bulletsCountImageName() -> String {
        return resources.bulletsCountImageBaseName + String(state.bulletsCount)
    }
}
