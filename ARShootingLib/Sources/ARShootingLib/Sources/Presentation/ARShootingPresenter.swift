//
//  ARShootingPresenter.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import Foundation

protocol ARShootingPresenterInterface: AnyObject {
    var currentWeaponId: Int { get }
    var targetHit: (() -> Void)? { get set }
    func getARView() -> AnyObject?
    func runSession()
    func pauseSession()
    func showWeapon(of id: Int)
    func renderWeaponFiring()
    func changeTargetsAppearance(to imageName: String)
}

final class ARShootingPresenter: ARShootingPresenterInterface {
    private let weaponRepository: WeaponRepositoryInterface
    private let view: ARShootingViewInterface
    private var loadedWeapons: [WeaponInfo] = []
    private(set) var currentWeaponId: Int = 0
    
    var targetHit: (() -> Void)?

    init(
        weaponRepository: WeaponRepositoryInterface,
        view: ARShootingViewInterface,
        targetCount: Int
    ) {
        self.weaponRepository = weaponRepository
        self.view = view
        self.view.setup(targetCount: targetCount)
    }
    
    func getARView() -> AnyObject? {
        return view.arView
    }
    
    func runSession() {
        view.runSession()
    }
    
    func pauseSession() {
        view.pauseSession()
    }
    
    func showWeapon(of id: Int) {
        let targetWeaponInfo = getWeaponInfo(of: id)
        currentWeaponId = targetWeaponInfo.id
        view.removeOtherWeaponNodes(except: targetWeaponInfo.id)
        view.showWeaponNode(of: targetWeaponInfo.id)
    }
    
    func renderWeaponFiring() {
        let isRecoilAnimationEnabled = getWeaponInfo(of: currentWeaponId).isRecoilAnimationEnabled
        view.renderWeaponFiring(isRecoilAnimationEnabled: isRecoilAnimationEnabled)
    }
    
    func changeTargetsAppearance(to imageName: String) {
        view.changeTargetsAppearance(to: imageName)
    }
    
    // MARK: Private Methods
    private func getWeaponInfo(of id: Int) -> WeaponInfo {
        // 既にロード済みの場合
        if let weaponInfo = loadedWeapons.first(where: { $0.id == id }) {
            return weaponInfo
        }
        // まだロードしていない場合
        else {
            // idを使って該当のWeaponInfoを取得
            let weaponInfo = weaponRepository.getWeaponInfo(by: id)
            
            // そのWeaponInfoを使って実際に3Dオブジェクト群（Node）をロードさせる
            view.prepareWeaponNodes(
                weaponId: id,
                weaponNodeInfo: (
                    fileName: weaponInfo.nodeFileName,
                    parentNodeName: weaponInfo.parentNodeName,
                    nodeName: weaponInfo.nodeName
                ),
                isGunnerHandShakingAnimationEnabled: weaponInfo.isGunnerHandShakingAnimationEnabled,
                particleNodeInfo: (
                    fileName: weaponInfo.targetHitParticleFileName,
                    nodeName: weaponInfo.targetHitParticleNodeName
                )
            )
            
            // ロード済みの武器のWeaponInfoを配列に保持
            loadedWeapons.append(weaponInfo)
            return weaponInfo
        }
    }
}
