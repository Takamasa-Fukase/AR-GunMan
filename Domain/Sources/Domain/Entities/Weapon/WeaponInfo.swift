//
//  WeaponInfo.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 5/11/24.
//

import Foundation

public struct WeaponInfo {
    public enum ReloadType {
        case manual
        case auto
    }
    
    public let isDefault: Bool
    public let capacity: Int
    public let reloadWaitingTimeMillisec: Int
    public let reloadType: ReloadType
    public let targetHitPoint: Int
    
    public init(
        isDefault: Bool,
        capacity: Int,
        reloadWaitingTimeMillisec: Int,
        reloadType: ReloadType,
        targetHitPoint: Int
    ) {
        self.isDefault = isDefault
        self.capacity = capacity
        self.reloadWaitingTimeMillisec = reloadWaitingTimeMillisec
        self.reloadType = reloadType
        self.targetHitPoint = targetHitPoint
    }
}
