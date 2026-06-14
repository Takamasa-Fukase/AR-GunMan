//
//  ARShootingController.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import SwiftUI

public protocol ARShootingControllerInterface: AnyObject {
    var targetHit: (() -> Void)? { get set }
    func runSession()
    func pauseSession()
    func showWeapon(of id: Int)
    func renderWeaponFiring()
    func changeTargetsAppearance(to imageName: String)
}

final class ARShootingController: ARShootingControllerInterface {
    private let presenter: ARShootingPresenterInterface
    
    init(presenter: ARShootingPresenterInterface) {
        self.presenter = presenter
    }
    
    var targetHit: (() -> Void)? {
        didSet {
            presenter.targetHit = targetHit
        }
    }
    
    func runSession() {
        presenter.runSession()
    }
    
    func pauseSession() {
        presenter.pauseSession()
    }
    
    func showWeapon(of id: Int) {
        presenter.showWeapon(of: id)
    }
    
    func renderWeaponFiring() {
        presenter.renderWeaponFiring()
    }
    
    func changeTargetsAppearance(to imageName: String) {
        presenter.changeTargetsAppearance(to: imageName)
    }
}
