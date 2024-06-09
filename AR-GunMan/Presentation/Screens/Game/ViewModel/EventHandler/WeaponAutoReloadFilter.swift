//
//  WeaponAutoReloadHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/5/24.
//

import RxSwift
import RxCocoa

final class WeaponAutoReloadFilter {
    struct Input {
        let weaponFired: Observable<WeaponType>
        let bulletsCount: Observable<Int>
    }
    
    struct Output {
        let reloadWeaponAutomatically: Observable<WeaponType>
    }
        
    func transform(input: Input) -> Output {
        let reloadWeaponAutomatically = input.weaponFired
            .withLatestFrom(input.bulletsCount) { (weaponType: $0, bulletsCount: $1) }
            .filter({ $0.bulletsCount == 0 && $0.weaponType.reloadType == .auto })
            .map({ $0.weaponType })

        return Output(reloadWeaponAutomatically: reloadWeaponAutomatically)
    }
}
