//
//  ARShootingControllerMock.swift
//  Device
//
//  Created by ウルトラ深瀬 on 2026/06/04.
//

import Foundation
import ARShootingEngine

public class ARShootingControllerMock: ARShootingControllerInterface {
    public var targetHit: ((WeaponType) -> Void)?
    
    public init() {}
    
    public func getARView() -> ARSCNViewRepresentable {
        return ARSCNViewRepresentable.createMock()
    }
    
    public func runSession() {}
    
    public func pauseSession() {}
    
    public func showWeapon(of type: WeaponType) {}
    
    public func renderWeaponFiring() {}
    
    public func changeTargetsAppearance() {}
}
