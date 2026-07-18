//
//  PistolInfo.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation

public struct PistolInfo: WeaponInfo {
    public let isDefault: Bool
    public let spec: Spec
    
    public init(
        isDefault: Bool,
        spec: Spec,
    ) {
        self.isDefault = isDefault
        self.spec = spec
    }
    
    public struct Spec: WeaponSpec {
        public let capacity: Int
        public let reloadWaitingTime: TimeInterval
        public let reloadWaitingTimeMillisec: Int
        public let reloadType: ReloadType
        public let targetHitPoint: Int
        
        public init(
            capacity: Int,
            reloadWaitingTime: TimeInterval,
            reloadWaitingTimeMillisec: Int,
            reloadType: ReloadType,
            targetHitPoint: Int
        ) {
            self.capacity = capacity
            self.reloadWaitingTime = reloadWaitingTime
            self.reloadWaitingTimeMillisec = reloadWaitingTimeMillisec
            self.reloadType = reloadType
            self.targetHitPoint = targetHitPoint
        }
    }
}
