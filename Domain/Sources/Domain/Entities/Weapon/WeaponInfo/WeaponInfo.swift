//
//  WeaponInfo.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 5/11/24.
//

import Foundation

public enum ReloadType {
    case manual
    case auto
}

public protocol WeaponSpec {
    var capacity: Int { get }
    var reloadWaitingTime: TimeInterval { get }
    var reloadWaitingTimeMillisec: Int { get }
    var reloadType: ReloadType { get }
    var targetHitPoint: Int { get }
}

public protocol WeaponInfo {
    associatedtype Spec: WeaponSpec
    
    var isDefault: Bool { get }
    var spec: Spec { get }
}
