//
//  ARShootingController.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import SwiftUI

public protocol ARShootingControllerInterface: AnyObject {
    var targetHit: (() -> Void)? { get set }
    func getARView() -> ARSCNViewRepresentable
    func runSession()
    func pauseSession()
    func showWeapon(of id: Int)
    func renderWeaponFiring()
    func changeTargetsAppearance(to imageName: String)
}

public final class ARShootingController: ARShootingControllerInterface {
    private let presenter: ARShootingPresenterInterface
    
    public init(
        frame: CGRect,
        targetCount: Int
    ) {
        presenter = ARShootingPresenterBuilder.build(
            frame: frame,
            targetCount: targetCount
        )
    }
    
    public var targetHit: (() -> Void)? {
        didSet {
            presenter.targetHit = targetHit
        }
    }
    
    public func getARView() -> ARSCNViewRepresentable {
        return ARSCNViewRepresentable(view: presenter.getARView())
    }
    
    public func runSession() {
        presenter.runSession()
    }
    
    public func pauseSession() {
        presenter.pauseSession()
    }
    
    public func showWeapon(of id: Int) {
        presenter.showWeapon(of: id)
    }
    
    public func renderWeaponFiring() {
        presenter.renderWeaponFiring()
    }
    
    public func changeTargetsAppearance(to imageName: String) {
        presenter.changeTargetsAppearance(to: imageName)
    }
}
