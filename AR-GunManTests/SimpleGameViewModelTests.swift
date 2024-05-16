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
    
    func test_pistolの残弾数が0の時に3回撃とうとしてもrenderWeaponFiringイベントが流れなければ成功() {
        let state = SimpleGameViewModel.State()
        // 残弾数を0にする
        state.bulletsCountRelay.accept(0)
        let viewModel = SimpleGameViewModel(state: state)
        
        let tryFiring3Times = scheduler.createHotObservable([
            .next(0, ()),
            .next(100, ()),
            .next(200, ())
        ])
        let input = SimpleGameViewModel.Input(
            inputFromGameScene: .init(targetHit: .empty()),
            inputFromCoreMotion: .init(
                firingMotionDetected: tryFiring3Times.asObservable(),
                reloadingMotionDetected: .empty()
            )
        )
        let output = viewModel.transform(input: input)
        // subscribeしないと動かないVM内部の処理を通常通り動かす為に一括でsubscribe
        subscribeAllVMActionEvents(output.viewModelAction)
        
        let renderWeaponFiringObserver = scheduler.createObserver(WeaponType.self)
        output.outputToGameScene.renderWeaponFiring
            .subscribe(renderWeaponFiringObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(renderWeaponFiringObserver.events, [])
    }
    
    func test_pistolの残弾数が0の時に3回撃とうとしても0のまま変わらなければ成功() {
        let state = SimpleGameViewModel.State()
        // 残弾数を0にする
        state.bulletsCountRelay.accept(0)
        let viewModel = SimpleGameViewModel(state: state)
        
        let tryFiring3Times = scheduler.createHotObservable([
            .next(100, ()),
            .next(200, ()),
            .next(300, ())
        ])
        let input = SimpleGameViewModel.Input(
            inputFromGameScene: .init(targetHit: .empty()),
            inputFromCoreMotion: .init(
                firingMotionDetected: tryFiring3Times.asObservable(),
                reloadingMotionDetected: .empty()
            )
        )
        let output = viewModel.transform(input: input)
        // subscribeしないと動かないVM内部の処理を通常通り動かす為に一括でsubscribe
        subscribeAllVMActionEvents(output.viewModelAction)
        
        let bulletsCountObserver = scheduler.createObserver(Int.self)
        state.bulletsCountRelay
            .subscribe(bulletsCountObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let expectedEvents: [Recorded] = [
            // bulletsCountRelayはBehaviorRelayな為subscribe時に現在値が一回流れるのでそれも含める
            .next(0, 0),
        ]
        
        print("実際のイベント: \(bulletsCountObserver.events)")
        print("期待値: \(expectedEvents)")
        
        XCTAssertEqual(bulletsCountObserver.events, expectedEvents)
    }
    
    func test_pistolの残弾数がMAXの7発の時に10回撃とうとしてもrenderWeaponFiringのイベントが7回しか流れなければ成功() {
        let state = SimpleGameViewModel.State()
        // 残弾数をMAXの7発にする
        state.bulletsCountRelay.accept(7)
        let viewModel = SimpleGameViewModel(state: state)
        
        // pistolの装弾数（7発）を超えて撃つイベントを作成
        let tryFiring10Times = scheduler.createHotObservable([
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
                firingMotionDetected: tryFiring10Times.asObservable(),
                reloadingMotionDetected: Observable.empty()
            )
        )
        let output = viewModel.transform(input: input)
        // subscribeしないと動かないVM内部の処理を通常通り動かす為に一括でsubscribe
        subscribeAllVMActionEvents(output.viewModelAction)
        
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
