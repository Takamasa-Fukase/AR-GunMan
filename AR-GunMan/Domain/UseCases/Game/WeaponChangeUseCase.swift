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
    func generateOutput(from input: WeaponChangeInput) -> WeaponChangeOutput
}

final class WeaponChangeUseCase: WeaponChangeUseCaseInterface {
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func generateOutput(from input: WeaponChangeInput) -> WeaponChangeOutput {
        // 🟥 Stateの更新指示<武器種別を変更>
        let updateWeaponType = input.weaponSelected
        
        // 🟥 Stateの更新指示<新しい武器のMaxの装弾数に補充>
        let refillBulletsCountForNewWeapon = input.weaponSelected
            .map({ $0.bulletsCapacity })
        
        // 🟥 Stateの更新指示<リロード中フラグをfalseにリセット>
        let resetWeaponReloadingFlag = input
            .weaponSelected.map({ _ in false })
        
        // 武器が変更されたことを通知
        let weaponChanged = input.weaponSelected
        
        disposeBag.insert {
            input.weaponSelected
                .subscribe(onNext: { [weak self] in
                    guard let self = self else {return}
                    // 🟨 音声の再生<武器を構える音>
                    self.soundPlayer.play($0.weaponChangingSound)
                })
        }
        
        return WeaponChangeOutput(
            updateWeaponType: updateWeaponType,
            refillBulletsCountForNewWeapon: refillBulletsCountForNewWeapon,
            resetWeaponReloadingFlag: resetWeaponReloadingFlag,
            weaponChanged: weaponChanged
        )
    }
}
