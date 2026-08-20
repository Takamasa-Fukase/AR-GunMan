//
//  ARGameEngineHandlerInterface.swift
//  DeviceInterface
//
//  Created by ウルトラ深瀬 on 2026/06/03.
//

import Foundation
import Domain

public protocol ARGameEngineHandlerInterface: AnyObject {
    var targetHit: ((WeaponType) -> Void)? { get set }
    func run()
    func pause()
    func showWeapon(of type: WeaponType)
    func renderWeaponFiring()
    func changeTargetsAppearance(to imageName: String)
}
