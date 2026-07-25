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

public final class ARShootingLibHandler: ARGameEngineHandlerInterface {
    public var targetHit: ((Domain.WeaponType) -> Void)?
    
    private let arShootingController: ARShootingControllerInterface
    
    public init(arShootingController: ARShootingControllerInterface) {
        self.arShootingController = arShootingController
        
        arShootingController.targetHit = { [weak self] weaponType in
            self?.targetHit?(weaponType.toDomainWeaponType)
        }
    }
    
    public func run() {
        arShootingController.runSession()
    }
    
    public func pause() {
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
