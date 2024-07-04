//
//  WeaponFireUseCaseTests.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 26/6/24.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import AR_GunMan

final class WeaponFireUseCaseTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var soundPlayer: MockSoundPlayer!
    var weaponFireUseCase: WeaponFireUseCase!
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(
            initialClock: 0,
            // 仮想時間をmillisecondsにする
            resolution: 0.001
        )
        disposeBag = DisposeBag()
        soundPlayer = .init()
        weaponFireUseCase = .init(soundPlayer: soundPlayer)
    }
    
    override func tearDown() {
        super.tearDown()
        scheduler = nil
        disposeBag = nil
        soundPlayer = nil
        weaponFireUseCase = nil
    }
    
    func test_全ての武器で_入力の弾が1で出力の弾が0_入出力の武器が同じ_各武器ごとの発射音声が再生されたら成功() {
        let allWeaponFireTriggers = scheduler.createHotObservable([
            .next(1, (weaponType: WeaponType.pistol, bulletsCount: 1)),
            .next(2, (weaponType: WeaponType.bazooka, bulletsCount: 1))
        ])
        let input = WeaponFireInput(
            weaponFiringTrigger: allWeaponFireTriggers.asObservable()
        )
        let output = weaponFireUseCase.generateOutput(from: input)
        let updateBulletsCountObserver = scheduler.createObserver(Int.self)
        let weaponFiredObserver = scheduler.createObserver(WeaponType.self)
        disposeBag.insert {
            output.updateBulletsCount
                .subscribe(updateBulletsCountObserver)
            output.weaponFired
                .subscribe(weaponFiredObserver)
        }
        
        scheduler.start()
        
        let updateBulletsCountObserverExpectedEvents: [Recorded] = [
            .next(1, 0),
            .next(2, 0)
        ]
        let weaponFiredObserverExpectedEvents: [Recorded] = [
            .next(1, WeaponType.pistol),
            .next(2, WeaponType.bazooka)
        ]
        let expectedPlayedSounds: [SoundType] = [
            .pistolShoot,
            .bazookaShoot
        ]
        
        XCTAssertEqual(updateBulletsCountObserver.events, updateBulletsCountObserverExpectedEvents)
        XCTAssertEqual(weaponFiredObserver.events, weaponFiredObserverExpectedEvents)
        XCTAssertEqual(soundPlayer.playedSounds, expectedPlayedSounds)
    }
    
    func test_全ての武器で_入力の弾が0の場合は弾も武器種別もイベントの出力はされず_ピストルだけは弾切れ音声が再生されてバズーカは何も再生されなければ成功() {
        let allWeaponFireTriggers = scheduler.createHotObservable([
            .next(1, (weaponType: WeaponType.pistol, bulletsCount: 0)),
            .next(2, (weaponType: WeaponType.bazooka, bulletsCount: 0))
        ])
        let input = WeaponFireInput(
            weaponFiringTrigger: allWeaponFireTriggers.asObservable()
        )
        let output = weaponFireUseCase.generateOutput(from: input)
        let updateBulletsCountObserver = scheduler.createObserver(Int.self)
        let weaponFiredObserver = scheduler.createObserver(WeaponType.self)
        disposeBag.insert {
            output.updateBulletsCount
                .subscribe(updateBulletsCountObserver)
            output.weaponFired
                .subscribe(weaponFiredObserver)
        }
        
        scheduler.start()
        
        let expectedPlayedSounds: [SoundType] = [
            .pistolOutBullets
        ]
        
        XCTAssertEqual(updateBulletsCountObserver.events, [])
        XCTAssertEqual(weaponFiredObserver.events, [])
        XCTAssertEqual(soundPlayer.playedSounds, expectedPlayedSounds)
    }
}
