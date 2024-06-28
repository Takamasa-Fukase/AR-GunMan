//
//  WeaponChangeUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct WeaponChangeInput {
    let weaponSelected: Observable<WeaponType>
}

struct WeaponChangeOutput {
    let updateWeaponType: Observable<WeaponType>
    let refillBulletsCountForNewWeapon: Observable<Int>
    let resetWeaponReloadingFlag: Observable<Bool>
    let weaponChanged: Observable<WeaponType>
}

protocol WeaponChangeUseCaseInterface {
    func transform(input: WeaponChangeInput) -> WeaponChangeOutput
}

final class WeaponChangeUseCase: WeaponChangeUseCaseInterface {
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: WeaponChangeInput) -> WeaponChangeOutput {
        disposeBag.insert {
            input.weaponSelected
                .subscribe(onNext: { [weak self] in
                    guard let self = self else {return}
                    self.soundPlayer.play($0.weaponChangingSound)
                })
        }
        
        return WeaponChangeOutput(
            updateWeaponType: input.weaponSelected,
            refillBulletsCountForNewWeapon: input.weaponSelected.map({ $0.bulletsCapacity }),
            resetWeaponReloadingFlag: input.weaponSelected.map({ _ in false }),
            weaponChanged: input.weaponSelected
        )
    }
}
