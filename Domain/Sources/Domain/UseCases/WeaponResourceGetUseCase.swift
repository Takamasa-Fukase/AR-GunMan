//
//  WeaponResourceGetUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 14/11/24.
//

import Foundation

public protocol WeaponResourceGetUseCaseInterface {
    func getDefaultWeaponDetail() -> CurrentWeaponData
    func getWeaponDetail(of weaponId: Int) -> CurrentWeaponData
    func getWeaponListItems() -> [WeaponListItem]
}

public final class WeaponResourceGetUseCase {
    private let weaponRepository: WeaponRepositoryInterface
    
    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
    }
}

extension WeaponResourceGetUseCase: WeaponResourceGetUseCaseInterface {
    public func getDefaultWeaponDetail() -> CurrentWeaponData {
        let weapon = weaponRepository.getDefault()
        return CurrentWeaponData(
            id: weapon.id,
            spec: .init(
                capacity: weapon.spec.capacity,
                reloadWaitingTime: weapon.spec.reloadWaitingTime,
                reloadType: weapon.spec.reloadType,
                targetHitPoint: weapon.spec.targetHitPoint
            ),
            resources: .init(
                weaponImageName: weapon.resources.weaponImageName,
                sightImageName: weapon.resources.sightImageName,
                sightImageColorType: weapon.resources.sightImageColorType,
                bulletsCountImageBaseName: weapon.resources.bulletsCountImageBaseName,
                appearingSound: weapon.resources.appearingSound,
                firingSound: weapon.resources.firingSound,
                reloadingSound: weapon.resources.reloadingSound,
                outOfBulletsSound: weapon.resources.outOfBulletsSound,
                bulletHitSound: weapon.resources.bulletHitSound
            ),
            state: .init(
                bulletsCount: weapon.spec.capacity,
                isReloading: false
            )
        )
    }
    
    public func getWeaponDetail(of weaponId: Int) -> CurrentWeaponData {
        let weapon = weaponRepository.get(by: weaponId)
        return CurrentWeaponData(
            id: weapon.id,
            spec: .init(
                capacity: weapon.spec.capacity,
                reloadWaitingTime: weapon.spec.reloadWaitingTime,
                reloadType: weapon.spec.reloadType,
                targetHitPoint: weapon.spec.targetHitPoint
            ),
            resources: .init(
                weaponImageName: weapon.resources.weaponImageName,
                sightImageName: weapon.resources.sightImageName,
                sightImageColorType: weapon.resources.sightImageColorType,
                bulletsCountImageBaseName: weapon.resources.bulletsCountImageBaseName,
                appearingSound: weapon.resources.appearingSound,
                firingSound: weapon.resources.firingSound,
                reloadingSound: weapon.resources.reloadingSound,
                outOfBulletsSound: weapon.resources.outOfBulletsSound,
                bulletHitSound: weapon.resources.bulletHitSound
            ),
            state: .init(
                bulletsCount: weapon.spec.capacity,
                isReloading: false
            )
        )
    }
    
    public func getWeaponListItems() -> [WeaponListItem] {
        let weapons = weaponRepository.getAll()
        return weapons.map { weapon in
            return WeaponListItem(weaponId: weapon.id,
                                  weaponImageName: weapon.resources.weaponImageName)
        }
    }
}
