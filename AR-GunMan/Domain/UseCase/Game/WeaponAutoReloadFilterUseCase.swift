//
//  WeaponAutoReloadFilterUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct WeaponAutoReloadFilterInput {
    let weaponFired: Observable<WeaponType>
    let bulletsCount: Observable<Int>
}

struct WeaponAutoReloadFilterOutput {
    let reloadWeaponAutomatically: Observable<WeaponType>
}

protocol WeaponAutoReloadFilterUseCaseInterface {
    func transform(input: WeaponAutoReloadFilterInput) -> WeaponAutoReloadFilterOutput
}

final class WeaponAutoReloadFilterUseCase: WeaponAutoReloadFilterUseCaseInterface {
    func transform(input: WeaponAutoReloadFilterInput) -> WeaponAutoReloadFilterOutput {
        let reloadWeaponAutomatically = input.weaponFired
            .withLatestFrom(input.bulletsCount) { (weaponType: $0, bulletsCount: $1) }
            .filter({ $0.bulletsCount == 0 && $0.weaponType.reloadType == .auto })
            .map({ $0.weaponType })

        return WeaponAutoReloadFilterOutput(
            reloadWeaponAutomatically: reloadWeaponAutomatically
        )
    }
}
