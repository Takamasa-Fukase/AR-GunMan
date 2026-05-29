//
//  ARShootingController2.swift
//  ARShooting
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import SwiftUI

public final class ARShootingController2 {
    private let presenter: ARShootingPresenterInterface
    
    public var view: some View {
        return ARSCNViewRepresentable(view: presenter.sceneView)
    }
    
    public init(
        frame: CGRect,
        delegate: ARShootingDelegate,
        targetCount: Int
    ) {
        let view = ARShootingView(
            frame: frame,
            delegate: delegate
        )
        presenter = ARShootingPresenter(
            view: view,
            targetCount: targetCount
        )
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
