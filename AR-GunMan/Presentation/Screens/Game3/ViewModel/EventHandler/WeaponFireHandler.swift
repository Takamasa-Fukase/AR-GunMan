//
//  WeaponFireHandler.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/24.
//

import RxSwift
import RxCocoa

final class WeaponFireHandler {
    struct Input {
        let weaponFiringTrigger: Observable<WeaponType>
        let bulletsCount: Observable<Int>
    }
    
    struct Output {
        let playNoBulletsSound: Observable<SoundType>
        let changeBulletsCount: Observable<Int>
        let playFiringSound: Observable<SoundType>
        let weaponFired: Observable<WeaponType>
    }
    
    func transform(input: Input) -> Output {
        let playNoBulletsSoundRelay = PublishRelay<SoundType>()
        let changeBulletsCountRelay = PublishRelay<Int>()
        let playFiringSoundRelay = PublishRelay<SoundType>()

        let weaponFired = input.weaponFiringTrigger
            .withLatestFrom(input.bulletsCount) {
                return (weaponType: $0, bulletsCount: $1)
            }
            .filter({
                guard $0.bulletsCount > 0 else {
                    if $0.weaponType.reloadType == .manual {
                        playNoBulletsSoundRelay.accept(.pistolOutBullets)
                    }
                    return false
                }
                return true
            })
            .do(onNext: {
                changeBulletsCountRelay.accept($0.bulletsCount - 1)
                playFiringSoundRelay.accept($0.weaponType.firingSound)
            })
            .map({ $0.weaponType })
        
        return Output(
            playNoBulletsSound: playNoBulletsSoundRelay.asObservable(),
            changeBulletsCount: changeBulletsCountRelay.asObservable(),
            playFiringSound: playFiringSoundRelay.asObservable(),
            weaponFired: weaponFired
        )
    }
}



