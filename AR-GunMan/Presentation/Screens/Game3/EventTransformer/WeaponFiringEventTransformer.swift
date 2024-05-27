//
//  WeaponFiringEventTransformer.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/24.
//

import RxSwift
import RxCocoa

final class WeaponFiringEventTransformer {
    struct Input {
        let weaponFiringTrigger: Observable<WeaponType>
    }
    
    struct Output {
        let weaponFired: Observable<WeaponType>
    }
    
    class State {
        let bulletsCountRelay: BehaviorRelay<Int>
        
        init(bulletsCountRelay: BehaviorRelay<Int>) {
            self.bulletsCountRelay = bulletsCountRelay
        }
    }
    
    private let soundPlayer: SoundPlayerInterface
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: Input, state: State) -> Output {
        var canFire: Bool {
            return state.bulletsCountRelay.value > 0
        }

        let weaponFired = input.weaponFiringTrigger
            .filter({ [weak self] weaponType in
                guard let self = self else { return false }
                guard canFire else {
                    if weaponType.reloadType == .manual {
                        self.soundPlayer.play(.pistolOutBullets)
                    }
                    return false
                }
                return true
            })
            .do(onNext: { [weak self] weaponType in
                guard let self = self else { return }
                self.soundPlayer.play(weaponType.firingSound)
                state.bulletsCountRelay.accept(
                    state.bulletsCountRelay.value - 1
                )
            })
        
        return Output(weaponFired: weaponFired)
    }
}



