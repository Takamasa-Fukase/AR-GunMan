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
    
    public var weaponInfo: any WeaponInfo {
        switch self {
        case .pistol:
            return PistolInfo(
                isDefault: true,
                spec: PistolInfo.Spec(
                    capacity: 7,
                    reloadWaitingTimeMillisec: 0,
                    reloadType: .manual,
                    targetHitPoint: 5
                )
            )
        case .bazooka:
            return BazookaInfo(
                isDefault: false,
                spec: BazookaInfo.Spec(
                    capacity: 1,
                    reloadWaitingTimeMillisec: 3200,
                    reloadType: .auto,
                    targetHitPoint: 12
                )
            )
        }
    }
    
    public static var defaultType: Self {
        guard let defaultWeaponType = allCases.first(where: { $0.weaponInfo.isDefault }) else {
            fatalError("デフォルトのWeaponTypeが存在しません")
        }
        return defaultWeaponType
    }
}
