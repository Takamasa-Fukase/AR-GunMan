//
//  SceneManagerStub.swift
//
//
//  Created by ウルトラ深瀬 on 20/12/24.
//

import Foundation
import ARKit
@testable import ARShooting

final class SceneManagerStub: SceneManagerInterface {
    var runSessionCalledCount = 0
    var pauseSessionCalledCount = 0
    var showWeaponObjectCalledValues = [Int]()
    var renderWeaponFiringCalledCount = 0
    var changeTargetsAppearanceCalledValues = [String]()
    var dummySceneView = DummySceneView()
    
    var targetHit: (() -> Void)?
    
    func getSceneView() -> ARSCNView {
        return dummySceneView
    }
    
    func runSession() {
        runSessionCalledCount += 1
    }
    
    func pauseSession() {
        pauseSessionCalledCount += 1
    }
    
    func showWeaponObject(weaponId: Int) {
        showWeaponObjectCalledValues.append(weaponId)
    }
    
    func renderWeaponFiring() {
        renderWeaponFiringCalledCount += 1
    }
    
    func changeTargetsAppearance(to imageName: String) {
        changeTargetsAppearanceCalledValues.append(imageName)
    }
}
