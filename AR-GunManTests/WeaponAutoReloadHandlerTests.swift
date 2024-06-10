//
//  WeaponAutoReloadHandlerTests.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 10/6/24.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import AR_GunMan

final class WeaponAutoReloadHandlerTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var weaponAutoReloadFilter: WeaponAutoReloadFilter!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        weaponAutoReloadFilter = WeaponAutoReloadFilter()
    }
    
    override func tearDown() {
        scheduler = nil
        disposeBag = nil
        weaponAutoReloadFilter = nil
    }
    
    func test_transform() {
        let fireWeapon = scheduler.createHotObservable([
            .next(100, WeaponType.bazooka)
        ])
        let bulletsCount = scheduler.createHotObservable([
            .next(0, 0)
        ])
        let input = WeaponAutoReloadFilter.Input(
            weaponFired: fireWeapon.asObservable(),
            bulletsCount: bulletsCount.asObservable()
        )
        let output = weaponAutoReloadFilter.transform(input: input)
        let reloadWeaponAutomaticallyObserver = scheduler.createObserver(WeaponType.self)
        output.reloadWeaponAutomatically
            .subscribe(reloadWeaponAutomaticallyObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let expectedEvents: [Recorded] = [
            .next(100, WeaponType.bazooka)
        ]
        
        XCTAssertEqual(reloadWeaponAutomaticallyObserver.events, expectedEvents)
    }
}
