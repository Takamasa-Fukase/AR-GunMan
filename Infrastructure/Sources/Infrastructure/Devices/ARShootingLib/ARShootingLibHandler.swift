//
//  ARShootingLibHandler.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/06/03.
//

import Foundation
import ARShootingLib
import Domain

public final class ARShootingLibHandler: ARShootingLibHandlerInterface {
    private let arShootingController: ARShootingControllerInterface
    private weak var delegate: ARShootingLibHandlerDelegate?
    
    public init(arShootingController: ARShootingControllerInterface) {
        self.arShootingController = arShootingController
    }
    
    public func inject(delegate: ARShootingLibHandlerDelegate) {
        self.delegate = delegate
        arShootingController.targetHit = { [weak self] in
            self?.delegate?.targetHit()
        }
    }
    
    public func runSession() {
        arShootingController.runSession()
    }
    
    public func pauseSession() {
        arShootingController.pauseSession()
    }
    
    public func showWeapon(of id: Int) {
        arShootingController.showWeapon(of: id)
    }
    
    public func renderWeaponFiring() {
        arShootingController.renderWeaponFiring()
    }
    
    public func changeTargetsAppearance(to imageName: String) {
        arShootingController.changeTargetsAppearance(to: imageName)
    }
}
