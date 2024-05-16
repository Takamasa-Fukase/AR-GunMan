//
//  SimpleGameViewModelTests.swift
//  AR-GunManTests
//
//  Created by 深瀬 on 2024/05/15.
//

import XCTest
import RxSwift
import RxTest
@testable import AR_GunMan

final class SimpleGameViewModelTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        scheduler = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func test_pistolを7発撃った後に撃とうとしてもrenderWeaponFiringのイベントが流れなければ成功() {
        let state = SimpleGameViewModel.State()
        let viewModel = SimpleGameViewModel(state: state)
        
        // pistolの装弾数（7発）を超えて撃つイベントを作成
        let fire10times = scheduler.createHotObservable([
            .next(100, ()),
            .next(200, ()),
            .next(300, ()),
            .next(400, ()),
            .next(500, ()),
            .next(600, ()),
            .next(700, ()),
            .next(800, ()),
            .next(900, ()),
            .next(1000, ()),
        ])
        
        let input = SimpleGameViewModel.Input(
            inputFromGameScene: SimpleGameViewModel.Input.InputFromGameScene(
                targetHit: Observable.empty()
            ),
            inputFromCoreMotion: SimpleGameViewModel.Input.InputFromCoreMotion(
                firingMotionDetected: fire10times.asObservable(),
                reloadingMotionDetected: Observable.empty()
            )
        )
        let output = viewModel.transform(input: input)
        
        let renderWeaponFiringObserver = scheduler.createObserver(WeaponType.self)
        output.outputToGameScene.renderWeaponFiring
            .subscribe(renderWeaponFiringObserver)
            .disposed(by: disposeBag)

        scheduler.start()
        
        let expectedEvents: [Recorded] = [
            .next(100, WeaponType.pistol),
            .next(200, WeaponType.pistol),
            .next(300, WeaponType.pistol),
            .next(400, WeaponType.pistol),
            .next(500, WeaponType.pistol),
            .next(600, WeaponType.pistol),
            .next(700, WeaponType.pistol)
        ]
        
        XCTAssertEqual(expectedEvents, renderWeaponFiringObserver.events)
    }
    
    private func subscribeAllVMActionEvents(
        _ viewModelAction: SimpleGameViewModel.Output.ViewModelAction
    ) {
        viewModelAction.fireWeapon
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModelAction.reloadWeapon
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModelAction.addScore
            .subscribe()
            .disposed(by: disposeBag)
    }
}
