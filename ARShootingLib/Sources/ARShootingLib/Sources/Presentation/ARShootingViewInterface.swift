//
//  ARShootingViewInterface.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/06/19.
//

import Foundation

protocol ARShootingViewInterface: AnyObject {
    var targetHit: (() -> Void)? { get set }
    func inject(presenter: ARShootingPresenterInterface)
    func runSession()
    func pauseSession()
    func loadAndSetupWeaponObjects(
        weaponId: Int,
        weaponResources: WeaponObjectResources,
        particleResources: TargetHitParticleResources?,
        isGunnerHandShakingAnimationEnabled: Bool
    )
    func showWeaponObject(of id: Int)
    func removeOtherWeaponObjects(except id: Int)
    func renderWeaponFiring(isRecoilAnimationEnabled: Bool)
    func changeTargetsAppearance(to imageName: String)
}
