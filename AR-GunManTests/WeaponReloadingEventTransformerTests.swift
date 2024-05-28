//
//  WeaponReloadHandlerTests.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 27/5/24.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import AR_GunMan

final class WeaponReloadHandlerTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var state: WeaponReloadHandler.State!
    var soundPlayer: SoundPlayerMock!
    var transformer: WeaponReloadHandler!
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        state = .init(
            bulletsCountRelay: BehaviorRelay<Int>(value: 0),
            isWeaponReloadingRelay: BehaviorRelay<Bool>(value: false)
        )
        soundPlayer = SoundPlayerMock()
        transformer = .init(
            gameUseCase: GameUseCase2(
                tutorialRepository: TutorialRepository(),
                timerRepository: TimerRepository()
            ),
            soundPlayer: soundPlayer
        )
    }
    
    override func tearDown() {
        scheduler = nil
        disposeBag = nil
        state = nil
        soundPlayer = nil
        transformer = nil
    }
    
    func test_pistolの残弾数が0の時にリロードしようとして0秒後にweaponReloadedにpistolTypeが一度だけ流れれば成功() {
        state.bulletsCountRelay.accept(0)
        let tryReload = scheduler.createHotObservable([
            .next(100, WeaponType.pistol)
        ])
        let input = WeaponReloadHandler.Input(
            weaponReloadingTrigger: tryReload.asObservable()
        )
        let output = transformer.transform(
            input: input,
            state: state
        )
        let weaponReloadedObserver = scheduler.createObserver(WeaponType.self)
        output.weaponReloaded
            .subscribe(weaponReloadedObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let expectedEvents: [Recorded] = [
            .next(100, WeaponType.pistol)
        ]
        
        XCTAssertEqual(weaponReloadedObserver.events, expectedEvents)
    }
}
