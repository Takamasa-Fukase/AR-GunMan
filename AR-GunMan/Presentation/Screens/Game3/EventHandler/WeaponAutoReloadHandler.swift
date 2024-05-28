//
//  WeaponAutoReloadHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/5/24.
//

import RxSwift
import RxCocoa

final class WeaponAutoReloadHandler {
    struct Input {
        let weaponFired: Observable<(weaponType: WeaponType, bulletsCount: Int)>
    }
    
    struct Output {
        let weaponAutoReloadTrigger: Observable<WeaponType>
    }
        
    func transform(input: Input) -> Output {
        let weaponAutoReloadTrigger = input.weaponFired
            .filter({ $0.bulletsCount == 0 && $0.weaponType.reloadType == .auto })
            .map({ $0.weaponType })

        return Output(weaponAutoReloadTrigger: weaponAutoReloadTrigger)
    }
}
