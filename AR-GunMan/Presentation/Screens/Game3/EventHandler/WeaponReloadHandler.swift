//
//  WeaponReloadHandler.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/24.
//

import RxSwift
import RxCocoa

final class WeaponReloadHandler {
    struct Input {
        let weaponReloadingTrigger: Observable<WeaponType>
    }
    
    struct Output {
        let weaponReloaded: Observable<WeaponType>
    }
    
    class State {
        let bulletsCountRelay: BehaviorRelay<Int>
        let isWeaponReloadingRelay: BehaviorRelay<Bool>

        init(bulletsCountRelay: BehaviorRelay<Int>,
             isWeaponReloadingRelay: BehaviorRelay<Bool>) {
            self.bulletsCountRelay = bulletsCountRelay
            self.isWeaponReloadingRelay = isWeaponReloadingRelay
        }
    }
    
    private let gameUseCase: GameUseCase2Interface
    private let soundPlayer: SoundPlayerInterface
    
    init(
        gameUseCase: GameUseCase2Interface,
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared
    ) {
        self.gameUseCase = gameUseCase
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: Input, state: State) -> Output {
        var canReload: Bool {
            return state.bulletsCountRelay.value <= 0 && !state.isWeaponReloadingRelay.value
        }
        let weaponReloaded = input.weaponReloadingTrigger
            .filter({ _ in canReload })
            .do(onNext: { [weak self] weaponType in
                guard let self = self else { return }
                state.isWeaponReloadingRelay.accept(true)
                self.soundPlayer.play(weaponType.reloadingSound)
            })
            .flatMapLatest({ [weak self] weaponType -> Observable<WeaponType> in
                guard let self = self else { return .empty() }
                return self.gameUseCase.awaitWeaponReloadEnds(currentWeapon: weaponType)
            })
            .filter({ _ in state.isWeaponReloadingRelay.value })
            .do(onNext: { weaponType in
                state.bulletsCountRelay.accept(
                    weaponType.bulletsCapacity
                )
                state.isWeaponReloadingRelay.accept(false)
            })
        
        return Output(weaponReloaded: weaponReloaded)
    }
}




