//
//  ARShootingEngineHandler.swift
//  Device
//
//  Created by ウルトラ深瀬 on 2026/06/03.
//

import Foundation
import ARShootingEngine
import Domain

public protocol ARShootingEngineHandlerInterface: AnyObject {
    var targetHit: ((Domain.WeaponType) -> Void)? { get set }
    func run()
    func pause()
    func showWeapon(of type: Domain.WeaponType)
    func renderWeaponFiring()
    func changeTargetsAppearance()
}

public final class ARShootingEngineHandler: ARShootingEngineHandlerInterface {
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
        arShootingController.showWeapon(of: type.toARShootingWeaponType)
    }
    
    public func renderWeaponFiring() {
        arShootingController.renderWeaponFiring()
    }
    
    public func changeTargetsAppearance() {
        arShootingController.changeTargetsAppearance()
    }
}

private extension Domain.WeaponType {
    var toARShootingWeaponType: ARShootingEngine.WeaponType {
        switch self {
        case .pistol:
            return .pistol
        case .bazooka:
            return .bazooka
        }
    }
}

private extension ARShootingEngine.WeaponType {
    var toDomainWeaponType: Domain.WeaponType {
        switch self {
        case .pistol:
            return .pistol
        case .bazooka:
            return .bazooka
        }
    }
}
