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
    func runSession()
    func pauseSession()
    func showWeapon(of id: Int)
    func renderWeaponFiring()
    func changeTargetsAppearance(to imageName: String)
}

final class ARShootingPresenter: ARShootingPresenterInterface {
    private let weaponRepository: WeaponRepositoryInterface
    private let view: ARShootingViewInterface
    private var loadedWeapons: [any WeaponObjectInfo] = []
    private(set) var currentWeaponId: Int = 0
    
    var targetHit: (() -> Void)? {
        didSet {
            view.targetHit = targetHit
        }
    }

    init(
        weaponRepository: WeaponRepositoryInterface,
        view: ARShootingViewInterface
    ) {
        self.weaponRepository = weaponRepository
        self.view = view
    }
    
    func runSession() {
        view.runSession()
    }
    
    func pauseSession() {
        view.pauseSession()
    }
    
    func showWeapon(of id: Int) {
        let targetWeaponObjectInfo = getWeaponObjectInfo(of: id)
        currentWeaponId = targetWeaponObjectInfo.id
        view.removeOtherWeaponObjects(except: targetWeaponObjectInfo.id)
        view.showWeaponObject(of: targetWeaponObjectInfo.id)
    }
    
    func renderWeaponFiring() {
        let isRecoilAnimationEnabled = getWeaponObjectInfo(of: currentWeaponId).isRecoilAnimationEnabled
        view.renderWeaponFiring(isRecoilAnimationEnabled: isRecoilAnimationEnabled)
    }
    
    func changeTargetsAppearance(to imageName: String) {
        view.changeTargetsAppearance(to: imageName)
    }
    
    // MARK: Private Methods
    private func getWeaponObjectInfo(of id: Int) -> any WeaponObjectInfo {
        // 既にロード済みの場合
        if let weaponObjectInfo = loadedWeapons.first(where: { $0.id == id }) {
            return weaponObjectInfo
        }
        // まだロードしていない場合
        else {
            // idを使って該当のWeaponInfoを取得
            let weaponObjectInfo = weaponRepository.getWeaponObjectInfo(by: id)
            
            // そのWeaponInfoを使って実際に3Dオブジェクト群（Node）をロードさせる
            view.loadAndSetupWeaponObjects(
                weaponId: weaponObjectInfo.id,
                weaponResources: weaponObjectInfo.weaponResources,
                particleResources: weaponObjectInfo.particleResources,
                isGunnerHandShakingAnimationEnabled: weaponObjectInfo.isGunnerHandShakingAnimationEnabled
            )
            
            // ロード済みの武器のWeaponInfoを配列に保持
            loadedWeapons.append(weaponObjectInfo)
            return weaponObjectInfo
        }
    }
}
