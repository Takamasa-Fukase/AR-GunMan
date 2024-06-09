//
//  WeaponReloadHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/5/24.
//

import RxSwift
import RxCocoa

final class WeaponReloadHandler: ViewModelEventHandlerType {
    struct Input {
        let weaponReloadingTrigger: Observable<WeaponType>
        let bulletsCount: Observable<Int>
        let isWeaponReloading: Observable<Bool>
    }
    
    struct Output {
        let changeBulletsCount: Observable<Int>
        let changeWeaponReloadingFlag: Observable<Bool>
        let playReloadingSound: Observable<SoundType>
        let weaponReloadProcessCompleted: Observable<WeaponType>
    }
    
    private let gameUseCase: GameUseCaseInterface
    
    init(gameUseCase: GameUseCaseInterface) {
        self.gameUseCase = gameUseCase
    }
    
    func transform(input: Input) -> Output {
        let changeBulletsCountRelay = PublishRelay<Int>()
        let changeWeaponReloadingFlagRelay = PublishRelay<Bool>()
        let playReloadingSoundRelay = PublishRelay<SoundType>()

        let weaponReloadProcessCompleted = input.weaponReloadingTrigger
            .withLatestFrom(Observable.combineLatest(
                input.bulletsCount,
                input.isWeaponReloading
            )) {
                return (weaponType: $0, bulletsCount: $1.0, isWeaponReloading: $1.1)
            }
            .filter({ $0.bulletsCount <= 0 && !$0.isWeaponReloading })
            .do(onNext: {
                changeWeaponReloadingFlagRelay.accept(true)
                playReloadingSoundRelay.accept($0.weaponType.reloadingSound)
            })
            .flatMapLatest({ [weak self] (weaponType, _, _) -> Observable<(weaponType: WeaponType, isWeaponReloading: Bool)> in
                guard let self = self else { return .empty() }
                return self.gameUseCase.awaitWeaponReloadEnds(currentWeapon: weaponType)
                    .withLatestFrom(input.isWeaponReloading) { ($0, $1) }
            })
            .filter({ $0.isWeaponReloading })
            .do(onNext: {
                changeBulletsCountRelay.accept($0.weaponType.bulletsCapacity)
                changeWeaponReloadingFlagRelay.accept(false)
            })
            .map({ $0.weaponType })
        
        return Output(
            changeBulletsCount: changeBulletsCountRelay.asObservable(),
            changeWeaponReloadingFlag: changeWeaponReloadingFlagRelay.asObservable(),
            playReloadingSound: playReloadingSoundRelay.asObservable(),
            weaponReloadProcessCompleted: weaponReloadProcessCompleted
        )
    }
}
