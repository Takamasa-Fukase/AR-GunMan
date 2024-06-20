//
//  WeaponFireUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct WeaponFireUseCaseInput {
    let weaponFiringTrigger: Observable<WeaponType>
    let bulletsCount: Observable<Int>
}

struct WeaponFireUseCaseOutput {
    let updateBulletsCount: Observable<Int>
    let weaponFired: Observable<WeaponType>
}

protocol WeaponFireUseCaseInterface {
    func transform(input: WeaponFireUseCaseInput) -> WeaponFireUseCaseOutput
}

final class WeaponFireUseCase: WeaponFireUseCaseInterface {
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: WeaponFireUseCaseInput) -> WeaponFireUseCaseOutput {
        let weaponTypeAndBulletsCount = input.weaponFiringTrigger
            .withLatestFrom(input.bulletsCount) {
                return (weaponType: $0, bulletsCount: $1)
            }
            .share()
        
        let noBullets = weaponTypeAndBulletsCount
            .filter({ $0.bulletsCount <= 0 })

        let fire = weaponTypeAndBulletsCount
            .filter({ $0.bulletsCount > 0 })
            .share()
        
        let updateBulletsCount = fire
            .map({ $0.bulletsCount - 1 })
        
        let weaponFired = fire
            .map({ $0.weaponType })
        
        disposeBag.insert {
            noBullets
                .filter({ $0.weaponType.reloadType == .manual })
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    self.soundPlayer.play(.pistolOutBullets)
                })
            fire
                .subscribe(onNext: { [weak self] in
                    guard let self = self else {return}
                    self.soundPlayer.play($0.weaponType.firingSound)
                })
        }
        
        return WeaponFireUseCaseOutput(
            updateBulletsCount: updateBulletsCount,
            weaponFired: weaponFired
        )
    }
}
