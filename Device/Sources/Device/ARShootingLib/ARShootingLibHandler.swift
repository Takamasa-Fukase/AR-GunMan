//
//  ARShootingLibHandler.swift
//  Device
//
//  Created by ウルトラ深瀬 on 2026/06/03.
//

import Foundation
import ARShootingLib
import Domain

public protocol ARGameEngineHandlerInterface: AnyObject {
    var targetHit: ((WeaponType) -> Void)? { get set }
    func run()
    func pause()
    func showWeapon(of type: WeaponType)
    func renderWeaponFiring()
    func changeTargetsAppearance(to imageName: String)
}

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
