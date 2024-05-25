////
////  WeaponReloadingEventTransformer.swift
////  AR-GunMan
////
////  Created by 深瀬 on 2024/05/24.
////
//
//import RxSwift
//import RxCocoa
//
//final class WeaponReloadingEventTransformer {
//    struct Input {
//        let weaponReloadingTrigger: Observable<WeaponType>
//    }
//    
//    struct Output {
//        let weaponReloaded: Observable<Void>
//    }
//    
//    private let soundPlayer: SoundPlayerInterface
//    
//    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
//        self.soundPlayer = soundPlayer
//    }
//    
//    func transform(
//        input: Input,
//        bulletsCountRelay: BehaviorRelay<Int>,
//        isWeaponReloadingRelay: BehaviorRelay<Bool>
//    ) -> Output {
//        var canReload: Bool {
//            return bulletsCountRelay.value <= 0 && !isWeaponReloadingRelay.value
//        }
//
//        let weaponReloaded = Observable
//            .combineLatest(
//                autoReloadRelay.asObservable(),
//                input.weaponReloadingTrigger
//            )
//            .filter({ canReload })
//            .do(onNext: { [weak self] _ in
//                guard let self = self else { return }
//                self.soundPlayer.play(WeaponType.pistol.reloadingSound)
//                bulletsCountRelay.accept(
//                    WeaponType.pistol.bulletsCapacity
//                )
//            })
//            .map({ _ in })
//        
//        return Output(
//            weaponReloaded: weaponReloaded
//        )
//    }
//}
//
//
//
//
