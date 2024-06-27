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

final class Tests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var soundPlayer: SoundPlayerMock!
    var weaponReloadUseCase: WeaponReloadUseCase!
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        soundPlayer = SoundPlayerMock()
        weaponReloadUseCase = .init(soundPlayer: soundPlayer)
    }
    
    override func tearDown() {
        scheduler = nil
        disposeBag = nil
        soundPlayer = nil
        weaponReloadUseCase = nil
    }
    
    func test_ピストルで_入力の弾が0で出力の弾が7_入力のリロード中フラグはfalseのまま変わらずで更新の出力は無し_ピストルのリロード音声が再生されれば成功() {
        let isWeaponReloadingRelay = BehaviorRelay<Bool>(value: false)
        
//        let initialWeaponReloadingFlag = scheduler.createHotObservable([
//            .next(0, false),
//            .next(1, true),
//        ])
        let weaponReloadingTrigger = scheduler.createHotObservable([
            .next(1, (weaponType: WeaponType.pistol, bulletsCount: 0))
        ])
        let input = WeaponReloadInput(
            weaponReloadingTrigger: weaponReloadingTrigger.asObservable(),
            isWeaponReloading: isWeaponReloadingRelay.asObservable()
        )
        let output = weaponReloadUseCase.transform(input: input)
        let updateBulletsCountObserver = scheduler.createObserver(Int.self)
//        let updateWeaponReloadingFlagObserver = scheduler.createObserver(Bool.self)
        disposeBag.insert {
            output.updateBulletsCount
                .subscribe(updateBulletsCountObserver)
//            output.updateWeaponReloadingFlag
//                .subscribe(updateWeaponReloadingFlagObserver)
            output.updateWeaponReloadingFlag
                .bind(to: isWeaponReloadingRelay)
        }
        
        scheduler.start()
        
        let updateBulletsCountObserverExpectedEvents: [Recorded] = [
            .next(1, 7)
        ]
//        let updateWeaponReloadingFlagObserverExpectedEvents: [Recorded] = [
//            .next(1, true)
//        ]
        let expectedPlayedSounds: [SoundType] = [
            .pistolReload
        ]
        
        XCTAssertEqual(updateBulletsCountObserver.events, updateBulletsCountObserverExpectedEvents)
//        XCTAssertEqual(updateWeaponReloadingFlagObserver.events, updateWeaponReloadingFlagObserverExpectedEvents)
        XCTAssertEqual(soundPlayer.playedSounds, expectedPlayedSounds)
    }
}