//
//  WeaponAutoReloadFilter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 3/7/24.
//

import RxSwift

final class WeaponAutoReloadFilter {
    static func filter(
        weaponFired: Observable<(weaponType: WeaponType, bulletsCount: Int)>
    ) -> Observable<WeaponType> {
        return weaponFired
            .filter({ $0.bulletsCount == 0 && $0.weaponType.reloadType == .auto })
            .map({ $0.weaponType })
    }
}
