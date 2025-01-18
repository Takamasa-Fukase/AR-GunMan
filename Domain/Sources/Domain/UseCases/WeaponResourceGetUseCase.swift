//
//  WeaponResourceGetUseCase.swift
//  WeaponFiringSimulator
//
//  Created by ウルトラ深瀬 on 14/11/24.
//

import Foundation

public protocol WeaponResourceGetUseCaseInterface {
    func getWeaponListItems() -> [WeaponListItem]
    func getDefaultWeaponDetail() throws -> CurrentWeaponData
    func getWeaponDetail(of weaponId: Int) throws -> CurrentWeaponData
}

public final class WeaponResourceGetUseCase {
    let weaponRepository: WeaponRepositoryInterface
    
    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
    }
}

extension WeaponResourceGetUseCase: WeaponResourceGetUseCaseInterface {
    public  func getWeaponListItems() -> [WeaponListItem] {
        let weapons = weaponRepository.getAll()
        return weapons.map { weapon in
            return WeaponListItem(weaponId: weapon.id,
                                  weaponImageName: weapon.resources.weaponImageName)
        }
    }
    
    public  func getDefaultWeaponDetail() throws -> CurrentWeaponData {
        let weapon = try weaponRepository.getDefault()
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
    
    public func getWeaponDetail(of weaponId: Int) throws -> CurrentWeaponData {
        let weapon = try weaponRepository.get(by: weaponId)
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
}
