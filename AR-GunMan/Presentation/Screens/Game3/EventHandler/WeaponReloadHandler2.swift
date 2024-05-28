//
//  WeaponReloader.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/5/24.
//

import RxSwift
import RxCocoa

final class WeaponReloadHandler2 {
    struct Input {
        let weaponReloadingTrigger: Observable<WeaponType>
        let currentBulletsCount: Observable<Int>
        let currentWeaponReloadingFlag: Observable<Bool>
    }
    
    struct Output {
        let bulletsCount: Observable<Int>
        let isWeaponReloading: Observable<Bool>
        let playReloadingSound: Observable<SoundType>
        let weaponReloaded: Observable<WeaponType>
    }
    
    private let gameUseCase: GameUseCase2Interface
    
    init(gameUseCase: GameUseCase2Interface) {
        self.gameUseCase = gameUseCase
    }
    
    func transform(input: Input) -> Output {
        let bulletsCountRelay = PublishRelay<Int>()
        let isWeaponReloadingRelay = PublishRelay<Bool>()
        let playReloadingSoundRelay = PublishRelay<SoundType>()

        let weaponReloaded = input.weaponReloadingTrigger
            .withLatestFrom(Observable.combineLatest(
                input.currentBulletsCount,
                input.currentWeaponReloadingFlag
            )) {
                return (weaponType: $0, bulletsCount: $1.0, isWeaponReloading: $1.1)
            }
            .filter({ $0.bulletsCount <= 0 && !$0.isWeaponReloading })
            .do(onNext: {
                isWeaponReloadingRelay.accept(true)
                playReloadingSoundRelay.accept($0.weaponType.reloadingSound)
            })
            .flatMapLatest({ [weak self] (weaponType, _, _) -> Observable<(weaponType: WeaponType, isWeaponReloading: Bool)> in
                guard let self = self else { return .empty() }
                return self.gameUseCase.awaitWeaponReloadEnds(currentWeapon: weaponType)
                    .withLatestFrom(input.currentWeaponReloadingFlag) { ($0, $1) }
            })
            .filter({ $0.isWeaponReloading })
            .do(onNext: {
                bulletsCountRelay.accept($0.weaponType.bulletsCapacity)
                isWeaponReloadingRelay.accept(false)
            })
            .map({ $0.weaponType })
        
        return Output(
            bulletsCount: bulletsCountRelay.asObservable(),
            isWeaponReloading: isWeaponReloadingRelay.asObservable(),
            playReloadingSound: playReloadingSoundRelay.asObservable(),
            weaponReloaded: weaponReloaded
        )
    }
}
