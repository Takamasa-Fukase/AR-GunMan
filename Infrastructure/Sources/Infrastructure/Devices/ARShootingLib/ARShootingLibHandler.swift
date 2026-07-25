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
    public let targetHitStream: AsyncStream<Domain.WeaponType>
    
    private let arShootingController: ARShootingControllerInterface
    
    public init(arShootingController: ARShootingControllerInterface) {
        self.arShootingController = arShootingController
        
        targetHitStream = AsyncStream<Domain.WeaponType>() { continuation in
            arShootingController.targetHit = { weaponType in
                continuation.yield(weaponType.toDomainWeaponType)
            }
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
