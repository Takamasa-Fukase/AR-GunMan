//
//  ARShootingLibHandlerInterface.swift
//  Devices
//
//  Created by ウルトラ深瀬 on 2026/06/03.
//

import Foundation
import Domain

public protocol ARShootingLibHandlerDelegate: AnyObject {
    func targetHit()
}

public protocol ARShootingLibHandlerInterface {
    func inject(delegate: ARShootingLibHandlerDelegate)
    func runSession()
    func pauseSession()
    func showWeapon(of type: WeaponType)
    func renderWeaponFiring()
    func changeTargetsAppearance(to imageName: String)
}
