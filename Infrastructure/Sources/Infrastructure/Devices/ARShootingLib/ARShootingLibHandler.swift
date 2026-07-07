//
//  ARShootingLibHandler.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/06/03.
//

import Foundation
import ARShootingLib
import DeviceInterface
import Domain

public final class ARShootingLibHandler: ARShootingLibHandlerInterface {
    private let arShootingController: ARShootingControllerInterface
    private weak var delegate: ARShootingLibHandlerDelegate?
    
    public init(arShootingController: ARShootingControllerInterface) {
        self.arShootingController = arShootingController
    }
    
    public func inject(delegate: ARShootingLibHandlerDelegate) {
        self.delegate = delegate
        arShootingController.targetHit = { [weak self] weaponType in
            self?.delegate?.targetHit(
                weaponType: weaponType.toDomainWeaponType
            )
        }
    }
    
    public func runSession() {
        arShootingController.runSession()
    }
    
    public func pauseSession() {
        arShootingController.pauseSession()
    }
    
    public func showWeapon(of type: Domain.WeaponType) {
        arShootingController.showWeapon(of: type.toARShootingLibWeaponType)
    }
    
    public func renderWeaponFiring() {
        arShootingController.renderWeaponFiring()
    }
    
    public func changeTargetsAppearance(to imageName: String) {
        arShootingController.changeTargetsAppearance(to: imageName)
    }
}

private extension Domain.WeaponType {
    var toARShootingLibWeaponType: ARShootingLib.WeaponType {
        switch self {
        case .pistol:
            return .pistol
        case .bazooka:
            return .bazooka
        }
    }
}

private extension ARShootingLib.WeaponType {
    var toDomainWeaponType: Domain.WeaponType {
        switch self {
        case .pistol:
            return .pistol
        case .bazooka:
            return .bazooka
        }
    }
}
