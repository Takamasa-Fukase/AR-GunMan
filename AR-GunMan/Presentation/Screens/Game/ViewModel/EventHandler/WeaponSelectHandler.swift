//
//  WeaponSelectHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 31/5/24.
//

import RxSwift
import RxCocoa

final class WeaponSelectHandler: ViewModelEventHandlerType {
    struct Input {
        let weaponSelected: Observable<WeaponType>
    }
    
    struct Output {
        let changeWeaponType: Observable<WeaponType>
        let playWeaponChangingSound: Observable<SoundType>
        let refillBulletsCountForNewWeapon: Observable<Int>
        let changeWeaponReloadingFlagForNewWeapon: Observable<Bool>
        let weaponChangeProcessCompleted: Observable<WeaponType>
    }
    
    func transform(input: Input) -> Output {
        return Output(
            changeWeaponType: input.weaponSelected,
            playWeaponChangingSound: input.weaponSelected.map({ $0.weaponChangingSound }),
            refillBulletsCountForNewWeapon: input.weaponSelected.map({ $0.bulletsCapacity }),
            changeWeaponReloadingFlagForNewWeapon: input.weaponSelected.map({ _ in false }),
            weaponChangeProcessCompleted: input.weaponSelected
        )
    }
}
