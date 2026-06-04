//
//  ARShootingControllerMock.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/06/04.
//

import Foundation
import ARShootingLib
import SwiftUI

public class ARShootingControllerMock: ARShootingControllerInterface {
    public var targetHit: (() -> Void)?
    
    public init() {}
    
    public func getARView() -> any View {
        return EmptyView()
    }
    
    public func runSession() {}
    
    public func pauseSession() {}
    
    public func showWeapon(of id: Int) {}
    
    public func renderWeaponFiring() {}
    
    public func changeTargetsAppearance(to imageName: String) {}
}
