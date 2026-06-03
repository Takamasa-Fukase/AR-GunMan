//
//  ARShootingController.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import SwiftUI

public protocol ARShootingControllerInterface {
    associatedtype ARView: View
    func getARView() -> ARView
    func inject(delegate: ARShootingDelegate)
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
    
    public func getARView() -> some View {
        return ARSCNViewRepresentable(view: presenter.arView)
    }
    
    public func inject(delegate: ARShootingDelegate) {
        presenter.inject(delegate: delegate)
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
