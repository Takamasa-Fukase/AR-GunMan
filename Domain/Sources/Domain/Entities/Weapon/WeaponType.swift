//
//  WeaponType.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/06/30.
//

import Foundation

public enum WeaponType: CaseIterable {
    case pistol
    case bazooka
    
    public enum ReloadType {
        case manual
        case auto
    }
    
    private struct WeaponInfo {
        let isDefault: Bool
        let capacity: Int
        let reloadWaitingTimeMillisec: Int
        let reloadType: ReloadType
        let targetHitPoint: Int
    }
    
    public static var defaultType: Self {
        guard let defaultWeaponType = allCases.first(where: { $0.isDefault }) else {
            fatalError("デフォルトのWeaponTypeが存在しません")
        }
        return defaultWeaponType
    }
    
    public var isDefault: Bool {
        return info.isDefault
    }
    
    public var capacity: Int {
        return info.capacity
    }
    
    public var reloadWaitingTimeMillisec: Int {
        return info.reloadWaitingTimeMillisec
    }
    
    public var reloadType: ReloadType {
        return info.reloadType
    }
    
    public var targetHitPoint: Int {
        return info.targetHitPoint
    }
    
    private var info: WeaponInfo {
        switch self {
        case .pistol:
            return WeaponInfo(
                isDefault: true,
                capacity: 7,
                reloadWaitingTimeMillisec: 0,
                reloadType: .manual,
                targetHitPoint: 5
            )
        case .bazooka:
            return WeaponInfo(
                isDefault: false,
                capacity: 1,
                reloadWaitingTimeMillisec: 3200,
                reloadType: .auto,
                targetHitPoint: 12
            )
        }
    }
}
