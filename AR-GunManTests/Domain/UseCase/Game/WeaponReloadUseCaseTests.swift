//
//  WeaponReloadUseCaseTests.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 26/6/24.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import AR_GunMan

final class WeaponReloadUseCaseTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var timerStreamCreator: TimerStreamCreator!
    var soundPlayer: MockSoundPlayer!
    var weaponReloadUseCase: WeaponReloadUseCase!
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(
            initialClock: 0,
            // 仮想時間をmillisecondsにする
            resolution: 0.001
        )
        disposeBag = DisposeBag()
        timerStreamCreator = .init(scheduler: scheduler)
        soundPlayer = .init()
        weaponReloadUseCase = .init(
            timerStreamCreator: timerStreamCreator,
            soundPlayer: soundPlayer
        )
    }
    
    override func tearDown() {
        super.tearDown()
        scheduler = nil
        disposeBag = nil
        timerStreamCreator = nil
        soundPlayer = nil
        weaponReloadUseCase = nil
    }

    func test_ピストルで_入力の弾が0で出力の弾が7_入力のリロード中フラグはfalseのまま変わらずで更新の出力は無し_ピストルのリロード音声が再生されれば成功_1() {
        let isWeaponReloadingRelay = BehaviorRelay<Bool>(value: false)
        
        let weaponReloadingTrigger = scheduler.createColdObservable([
            .next(1, (weaponType: WeaponType.pistol, bulletsCount: 0))
        ])
        let input = WeaponReloadInput(
            weaponReloadingTrigger: weaponReloadingTrigger.asObservable(),
            isWeaponReloading: isWeaponReloadingRelay.asObservable()
        )
        let output = weaponReloadUseCase.generateOutput(from: input)
        let updateBulletsCountObserver = scheduler.createObserver(Int.self)
        let updateWeaponReloadingFlagObserver = scheduler.createObserver(Bool.self)

        disposeBag.insert {
            output.updateBulletsCount
                .subscribe(updateBulletsCountObserver)
            output.updateWeaponReloadingFlag
                .subscribe(updateWeaponReloadingFlagObserver)
            output.updateWeaponReloadingFlag
                .bind(to: isWeaponReloadingRelay)
        }
        
        scheduler.start()
        
        let updateBulletsCountObserverExpectedEvents: [Recorded] = [
            // MEMO: pistolのリロード待ち時間は0 millisecだが、
            // timerを使うと0でも最低+1経過するので+1している（0=>1, 1=>1, 2=>2...)
            .next(2, 7)
        ]
        let updateWeaponReloadingFlagObserverExpectedEvents: [Recorded] = [
            .next(1, true),
            .next(2, false)
        ]
        let expectedPlayedSounds: [SoundType] = [
            .pistolReload
        ]
        
        XCTAssertEqual(updateBulletsCountObserver.events, updateBulletsCountObserverExpectedEvents)
        XCTAssertEqual(updateWeaponReloadingFlagObserver.events, updateWeaponReloadingFlagObserverExpectedEvents)
        XCTAssertEqual(soundPlayer.playedSounds, expectedPlayedSounds)
    }
}
