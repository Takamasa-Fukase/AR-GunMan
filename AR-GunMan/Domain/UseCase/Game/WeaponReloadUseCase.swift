//
//  WeaponReloadUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct WeaponReloadInput {
    let weaponReloadingTrigger: Observable<(weaponType: WeaponType, bulletsCount: Int)>
    let isWeaponReloading: Observable<Bool>
}

struct WeaponReloadOutput {
    let updateBulletsCount: Observable<Int>
    let updateWeaponReloadingFlag: Observable<Bool>
}

protocol WeaponReloadUseCaseInterface {
    func transform(input: WeaponReloadInput) -> WeaponReloadOutput
}

final class WeaponReloadUseCase: WeaponReloadUseCaseInterface {
    private let timerStreamCreator: TimerStreamCreator
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(
        timerStreamCreator: TimerStreamCreator = TimerStreamCreator(),
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared
    ) {
        self.timerStreamCreator = timerStreamCreator
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: WeaponReloadInput) -> WeaponReloadOutput {
        let isWeaponReloadingRelay = PublishRelay<Bool>()

        let weaponTypeAndBulletsCountAndReloadingFlag = input.weaponReloadingTrigger
            .withLatestFrom(input.isWeaponReloading) {
                return (weaponType: $0.0, bulletsCount: $0.1, isWeaponReloading: $1)
            }
            .share()
        
        let reload = weaponTypeAndBulletsCountAndReloadingFlag
            .filter({ $0.bulletsCount <= 0 && !$0.isWeaponReloading })
            .share()
        
        // MEMO: リロードの待ち時間の間に武器が変更された場合はisWeaponReloadingが
        // falseにリセットされるので、リロード完了時点の最新値を取得してフィルターする
        let weaponReloadWaitTimeEnded = reload
            .flatMapLatest({ [weak self] (weaponType, _, _) in
                guard let self = self else {
                    return Observable<(weaponType: WeaponType, isWeaponReloading: Bool)>.empty()
                }
                return self.timerStreamCreator
                    .create(
                        milliSec: weaponType.reloadWaitingTimeMillisec,
                        isRepeated: false
                    )
                    .withLatestFrom(input.isWeaponReloading) {
                        return (weaponType: weaponType, isWeaponReloading: $1)
                    }
            })
            .filter({ $0.isWeaponReloading })
            .map({ $0.weaponType })
            .share()
        
        let updateBulletsCount = weaponReloadWaitTimeEnded
            .map({ $0.bulletsCapacity })
        
        disposeBag.insert {
            reload
                .subscribe(onNext: { [weak self] in
                    guard let self = self else {return}
                    self.soundPlayer.play($0.weaponType.reloadingSound)
                    isWeaponReloadingRelay.accept(true)
                })
            weaponReloadWaitTimeEnded
                .subscribe(onNext: { _ in
                    isWeaponReloadingRelay.accept(false)
                })
        }
        
        return WeaponReloadOutput(
            updateBulletsCount: updateBulletsCount,
            updateWeaponReloadingFlag: isWeaponReloadingRelay.asObservable()
        )
    }
}
