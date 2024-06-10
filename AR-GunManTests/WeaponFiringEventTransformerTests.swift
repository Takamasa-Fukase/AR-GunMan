//
//  WeaponFireHandlerTests.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 25/5/24.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import AR_GunMan

//final class WeaponFireHandlerTests: XCTestCase {
//    var scheduler: TestScheduler!
//    var disposeBag: DisposeBag!
//    var state: WeaponFireHandler.State!
//    var soundPlayer: SoundPlayerMock!
//
//    override func setUp() {
//        super.setUp()
//        scheduler = TestScheduler(initialClock: 0)
//        disposeBag = DisposeBag()
//        state = .init(
//            bulletsCountRelay: BehaviorRelay<Int>(value: 0)
//        )
//        soundPlayer = SoundPlayerMock()
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//        scheduler = nil
//        disposeBag = nil
//        state = nil
//        soundPlayer = nil
//    }
//    
//    func test_pistolの残弾数が0の時に3回撃とうとしてもweaponFiredイベントが流れなければ成功() {
//        // 残弾数を0にする
//        state.bulletsCountRelay.accept(0)
//        let transformer = WeaponFireHandler()
//        
//        let tryFiringPistol3Times = scheduler.createHotObservable([
//            .next(0,  WeaponType.pistol),
//            .next(100, WeaponType.pistol),
//            .next(200, WeaponType.pistol)
//        ])
//        let input = WeaponFireHandler.Input(
//            weaponFiringTrigger: tryFiringPistol3Times.asObservable()
//        )
//        let output = transformer.transform(
//            input: input,
//            state: state
//        )
//        
//        let weaponFiredObserver = scheduler.createObserver(WeaponType.self)
//        output.weaponFired
//            .subscribe(weaponFiredObserver)
//            .disposed(by: disposeBag)
//        
//        scheduler.start()
//        
//        XCTAssertEqual(weaponFiredObserver.events, [])
//    }
//    
//    func test_pistolの残弾数が0の時に3回撃とうとしても0のまま変わらなければ成功() {
//        // 残弾数を0にする
//        state.bulletsCountRelay.accept(0)
//        let transformer = WeaponFireHandler()
//        
//        let tryFiringPistol3Times = scheduler.createHotObservable([
//            .next(0, WeaponType.pistol),
//            .next(100, WeaponType.pistol),
//            .next(200, WeaponType.pistol)
//        ])
//        let input = WeaponFireHandler.Input(
//            weaponFiringTrigger: tryFiringPistol3Times.asObservable()
//        )
//        let output = transformer.transform(
//            input: input,
//            state: state
//        )
//        output.weaponFired
//            .subscribe()
//            .disposed(by: disposeBag)
//        
//        let bulletsCountObserver = scheduler.createObserver(Int.self)
//        state.bulletsCountRelay
//            .subscribe(bulletsCountObserver)
//            .disposed(by: disposeBag)
//        
//        scheduler.start()
//        
//        let expectedEvents: [Recorded] = [
//            // bulletsCountRelayはBehaviorRelayな為subscribe時に現在値が一回流れるのでそれも含める
//            .next(0, 0),
//        ]
//
//        XCTAssertEqual(bulletsCountObserver.events, expectedEvents)
//    }
//    
//    func test_pistolの残弾数が0の時に3回撃とうとしてpistolOutBulletsの音声再生処理が3回呼ばれれば成功() {
//        // 残弾数を0にする
//        state.bulletsCountRelay.accept(0)
//        let transformer = WeaponFireHandler(soundPlayer: soundPlayer)
//
//        let tryFiringPistol3Times = scheduler.createHotObservable([
//            .next(0, WeaponType.pistol),
//            .next(100, WeaponType.pistol),
//            .next(200, WeaponType.pistol)
//        ])
//        let input = WeaponFireHandler.Input(
//            weaponFiringTrigger: tryFiringPistol3Times.asObservable()
//        )
//        let output = transformer.transform(
//            input: input,
//            state: state
//        )
//        output.weaponFired
//            .subscribe()
//            .disposed(by: disposeBag)
//        
//        scheduler.start()
//        
//        XCTAssertTrue(soundPlayer.isPlayCalled)
//        XCTAssertEqual(soundPlayer.playedSound, .pistolOutBullets)
//        XCTAssertEqual(soundPlayer.playCalledCount, 3)
//    }
//    
//    func test_pistolの残弾数がMAXの7発の時に10回撃とうとしてもweaponFiredのイベントが7回しか流れなければ成功() {
//        // 残弾数をMAXの7発にする
//        state.bulletsCountRelay.accept(7)
//        let transformer = WeaponFireHandler()
//
//        // pistolの装弾数（7発）を超えて撃つイベントを作成
//        let tryFiringPistol10Times = scheduler.createHotObservable([
//            .next(0, WeaponType.pistol),
//            .next(100, WeaponType.pistol),
//            .next(200, WeaponType.pistol),
//            .next(300, WeaponType.pistol),
//            .next(400, WeaponType.pistol),
//            .next(500, WeaponType.pistol),
//            .next(600, WeaponType.pistol),
//            .next(700, WeaponType.pistol),
//            .next(800, WeaponType.pistol),
//            .next(900, WeaponType.pistol)
//        ])
//        
//        let input = WeaponFireHandler.Input(
//            weaponFiringTrigger: tryFiringPistol10Times.asObservable()
//        )
//        let output = transformer.transform(
//            input: input,
//            state: state
//        )
//        
//        let weaponFiredObserver = scheduler.createObserver(WeaponType.self)
//        output.weaponFired
//            .subscribe(weaponFiredObserver)
//            .disposed(by: disposeBag)
//
//        scheduler.start()
//        
//        let expectedEvents: [Recorded] = [
//            .next(0, WeaponType.pistol),
//            .next(100, WeaponType.pistol),
//            .next(200, WeaponType.pistol),
//            .next(300, WeaponType.pistol),
//            .next(400, WeaponType.pistol),
//            .next(500, WeaponType.pistol),
//            .next(600, WeaponType.pistol),
//        ]
//        
//        XCTAssertEqual(expectedEvents, weaponFiredObserver.events)
//    }
//    
//    func test_pistolの残弾数がMAXの7発の時に7回撃とうとしてpistolShootの音声再生処理が7回呼ばれれば成功() {
//        // 残弾数をMAXの7発にする
//        state.bulletsCountRelay.accept(7)
//        let transformer = WeaponFireHandler(soundPlayer: soundPlayer)
//
//        let tryFiringPistol7Times = scheduler.createHotObservable([
//            .next(0, WeaponType.pistol),
//            .next(100, WeaponType.pistol),
//            .next(200, WeaponType.pistol),
//            .next(300, WeaponType.pistol),
//            .next(400, WeaponType.pistol),
//            .next(500, WeaponType.pistol),
//            .next(600, WeaponType.pistol),
//        ])
//        let input = WeaponFireHandler.Input(
//            weaponFiringTrigger: tryFiringPistol7Times.asObservable()
//        )
//        let output = transformer.transform(
//            input: input,
//            state: state
//        )
//        output.weaponFired
//            .subscribe()
//            .disposed(by: disposeBag)
//        
//        scheduler.start()
//        
//        XCTAssertTrue(soundPlayer.isPlayCalled)
//        XCTAssertEqual(soundPlayer.playedSound, WeaponType.pistol.firingSound)
//        XCTAssertEqual(soundPlayer.playCalledCount, 7)
//    }
//}
