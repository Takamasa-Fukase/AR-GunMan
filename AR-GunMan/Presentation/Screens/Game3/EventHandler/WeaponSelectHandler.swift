//
//  WeaponSelectHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 31/5/24.
//

import RxSwift
import RxCocoa

final class WeaponSelectHandler {
    struct Input {
        let weaponSelected: Observable<WeaponType>
    }
    
    struct Output {
        let changeWeaponType: Observable<WeaponType>
        let playWeaponChangingSound: Observable<SoundType>
        let refillBulletsCountForNewWeapon: Observable<Int>
        let changeWeaponReloadingFlagForNewWeapon: Observable<Bool>
        let weaponChanged: Observable<WeaponType>
    }
    
    func transform(input: Input) -> Output {
        let changeWeaponTypeRelay = PublishRelay<WeaponType>()
        let playWeaponChangingSoundRelay = PublishRelay<SoundType>()
        let refillBulletsCountRelay = PublishRelay<Int>()
        let changeWeaponReloadingFlagRelay = PublishRelay<Bool>()
        
        let weaponChanged = input.weaponSelected
            .do(onNext: { weaponType in
                changeWeaponTypeRelay.accept(weaponType)
                playWeaponChangingSoundRelay.accept(weaponType.weaponChangingSound)
                refillBulletsCountRelay.accept(weaponType.bulletsCapacity)
                changeWeaponReloadingFlagRelay.accept(false)
            })
        
        return Output(
            changeWeaponType: changeWeaponTypeRelay.asObservable(),
            playWeaponChangingSound: playWeaponChangingSoundRelay.asObservable(),
            refillBulletsCountForNewWeapon: refillBulletsCountRelay.asObservable(),
            changeWeaponReloadingFlagForNewWeapon: changeWeaponReloadingFlagRelay.asObservable(),
            weaponChanged: weaponChanged
        )
    }
}
