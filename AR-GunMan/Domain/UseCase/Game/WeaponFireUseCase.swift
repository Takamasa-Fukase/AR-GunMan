//
//  WeaponFireUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct WeaponFireInput {
    let weaponFiringTrigger: Observable<(weaponType: WeaponType, bulletsCount: Int)>
}

struct WeaponFireOutput {
    let updateBulletsCount: Observable<Int>
    let weaponFired: Observable<WeaponType>
}

protocol WeaponFireUseCaseInterface {
    func transform(input: WeaponFireInput) -> WeaponFireOutput
}

final class WeaponFireUseCase: WeaponFireUseCaseInterface {
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: WeaponFireInput) -> WeaponFireOutput {
        let updateBulletsCountRelay = PublishRelay<Int>()
        let weaponFiredRelay = PublishRelay<WeaponType>()

        let noBullets = input.weaponFiringTrigger
            .filter({ $0.bulletsCount <= 0 })

        let fire = input.weaponFiringTrigger
            .filter({ $0.bulletsCount > 0 })
            .share()

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
                    updateBulletsCountRelay.accept($0.bulletsCount - 1)
                    weaponFiredRelay.accept($0.weaponType)
                })
        }
        
        return WeaponFireOutput(
            updateBulletsCount: updateBulletsCountRelay.asObservable(),
            weaponFired: weaponFiredRelay.asObservable()
        )
    }
}
