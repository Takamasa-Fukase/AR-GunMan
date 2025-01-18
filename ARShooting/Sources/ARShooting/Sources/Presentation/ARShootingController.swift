//
//  ARShootingController.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 15/12/24.
//

import UIKit
import SwiftUI

public final class ARShootingController {
    public var targetHit: (() -> Void)? {
        didSet {
            sceneManager.targetHit = targetHit
        }
    }
    public var view: some View {
        return SceneViewRepresentable(view: sceneManager.getSceneView())
    }
    private var sceneManager: SceneManagerInterface
    
    public init(frame: CGRect) {
        sceneManager = SceneManager(frame: frame)
    }
    
    // MARK: ユニットテスト時のみアクセスする
    #if DEBUG
    init(sceneManager: SceneManagerInterface) {
        self.sceneManager = sceneManager
    }
    #endif
    
    public func runSession() {
        sceneManager.runSession()
    }
    
    public func pauseSession() {
        sceneManager.pauseSession()
    }
    
    public func showWeaponObject(weaponId: Int) {
        sceneManager.showWeaponObject(weaponId: weaponId)
    }
    
    public func renderWeaponFiring() {
        sceneManager.renderWeaponFiring()
    }
    
    public func changeTargetsAppearance(to imageName: String) {
        sceneManager.changeTargetsAppearance(to: imageName)
    }
}
