//
//  WeaponReloadingEventTransformer.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/24.
//

import RxSwift
import RxCocoa

final class WeaponReloadingEventTransformer {
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
            print("canReload: \(state.bulletsCountRelay.value <= 0 && !state.isWeaponReloadingRelay.value)")
            return state.bulletsCountRelay.value <= 0 && !state.isWeaponReloadingRelay.value
        }
        let weaponReloaded = input.weaponReloadingTrigger
            .filter({ _ in canReload })
            .do(onNext: { [weak self] weaponType in
                print("first do weaponType: \(weaponType)")
                guard let self = self else { return }
                state.isWeaponReloadingRelay.accept(true)
                print("first do isWeaponReloadingRelay.accept(true), state.value: \(state.isWeaponReloadingRelay.value)")
                self.soundPlayer.play(weaponType.reloadingSound)
                print("first do soundPlayer.play(weaponType.reloadingSound)")
            })
            .flatMapLatest({ [weak self] weaponType -> Observable<WeaponType> in
                print("flatMapLatest selfチェック前")
                guard let self = self else { return Observable.empty() }
                print("flatMapLatest selfチェック通過後")
                return self.gameUseCase.awaitWeaponReloadEnds(currentWeapon: weaponType)
            })
            .filter({ _ in state.isWeaponReloadingRelay.value })
            .do(onNext: { weaponType in
                print("second do weaponType: \(weaponType)")
                state.bulletsCountRelay.accept(
                    weaponType.bulletsCapacity
                )
                print("second do bulletsCountRelay.accept(\(weaponType.bulletsCapacity), state.value:  \(state.bulletsCountRelay.value)")
                state.isWeaponReloadingRelay.accept(false)
                print("second do isWeaponReloadingRelay.accept(false), state.value:  \(state.isWeaponReloadingRelay.value)")
            })
        
        return Output(weaponReloaded: weaponReloaded)
    }
}




