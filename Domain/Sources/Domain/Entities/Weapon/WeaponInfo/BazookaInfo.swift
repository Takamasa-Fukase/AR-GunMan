//
//  BazookaInfo.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation

public struct BazookaInfo: WeaponInfo {
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
        public let reloadWaitingTimeMillisec: Int
        public let reloadType: ReloadType
        public let targetHitPoint: Int
        
        public init(
            capacity: Int,
            reloadWaitingTimeMillisec: Int,
            reloadType: ReloadType,
            targetHitPoint: Int
        ) {
            self.capacity = capacity
            self.reloadWaitingTimeMillisec = reloadWaitingTimeMillisec
            self.reloadType = reloadType
            self.targetHitPoint = targetHitPoint
        }
    }
}
