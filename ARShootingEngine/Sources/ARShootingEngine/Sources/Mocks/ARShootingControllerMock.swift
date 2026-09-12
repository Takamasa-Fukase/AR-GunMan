//
//  ARShootingControllerMock.swift
//  ARShootingEngine
//
//  Created by ウルトラ深瀬 on 2026/06/04.
//

import Foundation

public class ARShootingControllerMock: ARShootingControllerInterface {
    public var targetHit: ((WeaponType) -> Void)?
    
    public init() {}
    
    public func runSession() {}
    
    public func pauseSession() {}
    
    public func showWeapon(of type: WeaponType) {}
    
    public func renderWeaponFiring() {}
    
    public func changeTargetsAppearance() {}
}
