//
//  GameViewModelTests.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 5/2/25.
//

import XCTest
import Domain
import Combine
@testable import AR_GunMan_Dev

final class GameViewModelTests: XCTestCase {
    private let testData = GameViewModelTestsTestData()
    private var gameViewModel: GameViewModel!
    private var cancellables: [AnyCancellable] = []
    
    override func setUp() {
        gameViewModel = .init(
            tutorialRepository: RepositoryFactory.create(),
            gameTimerCreateUseCase: UseCaseFactory.create(),
            weaponResourceGetUseCase: UseCaseFactory.create(),
            weaponActionExecuteUseCase: UseCaseFactory.create()
        )
    }
    
    override func tearDown() {
        gameViewModel = nil
    }
    
    
    // MARK: fireMotionDetected()メソッドのテスト
    /*
     テストしたいパターン一覧
     - 残弾数 = 1以上, リロード中 = false, リロードタイプ = .manual の時
     - 残弾数 = 0　　, リロード中 = false, リロードタイプ = .manual の時
     - 残弾数 = 0　　, リロード中 = true , リロードタイプ = .manual の時
     - 残弾数 = 1以上, リロード中 = false, リロードタイプ = .auto   の時
     - 残弾数 = 0　　, リロード中 = false, リロードタイプ = .auto   の時
     - 残弾数 = 0　　, リロード中 = true , リロードタイプ = .auto   の時
     
     テストしたい項目
     <onFiredの処理>
     - bulletsCountが元の残弾数よりも1少ない値になっていること
     - arEventで.renderWeaponFiringが流れてくること
     - playSoundで現在の武器のfiringSoundが流れてくること
     - needsAutoReloadがtrueの時にreloadWeaponが呼ばれること
     <onOutOfBulletsの処理>
     - 現在の武器に弾切れ音声が存在する場合にplaySoundで弾切れ音声が流れること
     */
    
    func test_fireMotionDetected_残弾数＝1以上_リロード中＝false_リロードタイプ＝manualの時() {
        let currentWeapon = CurrentWeapon(
            weapon: testData.pistol,
            state: .init(
                bulletsCount: 1,
                isReloading: false
            )
        )
        // テスト用のデータをセット
        gameViewModel.setCurrentWeapon(currentWeapon)
                
        var outputEventReceivedValues: [GameViewModel.OutputEventType] = []
        
        gameViewModel.outputEvent
            .sink { outputEventReceivedValues.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 1)
        XCTAssertEqual(outputEventReceivedValues, [])
        
        // テスト対象のメソッドを実行
        gameViewModel.fireMotionDetected()
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [
            .arControllerInputEvent(.renderWeaponFiring),
            .playSound(.pistolFire)
        ])
    }
    
    func test_fireMotionDetected_残弾数＝0_リロード中＝false_リロードタイプ＝manualの時() {
        let currentWeapon = CurrentWeapon(
            weapon: testData.pistol,
            state: .init(
                bulletsCount: 0,
                isReloading: false
            )
        )
        // テスト用のデータをセット
        gameViewModel.setCurrentWeapon(currentWeapon)
                
        var outputEventReceivedValues: [GameViewModel.OutputEventType] = []
        
        gameViewModel.outputEvent
            .sink { outputEventReceivedValues.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [])
        
        // テスト対象のメソッドを実行
        gameViewModel.fireMotionDetected()
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [
            .playSound(.pistolOutOfBullets)
        ])
    }
    
    func test_fireMotionDetected_残弾数＝0_リロード中＝true_リロードタイプ＝manualの時() {
        let currentWeapon = CurrentWeapon(
            weapon: testData.pistol,
            state: .init(
                bulletsCount: 0,
                isReloading: true
            )
        )
        // テスト用のデータをセット
        gameViewModel.setCurrentWeapon(currentWeapon)
                
        var outputEventReceivedValues: [GameViewModel.OutputEventType] = []
        
        gameViewModel.outputEvent
            .sink { outputEventReceivedValues.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [])
        
        // テスト対象のメソッドを実行
        gameViewModel.fireMotionDetected()
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [
            .playSound(.pistolOutOfBullets)
        ])
    }
    
    func test_fireMotionDetected_残弾数＝1以上_リロード中＝false_リロードタイプ＝autoの時() {
        let currentWeapon = CurrentWeapon(
            weapon: testData.bazooka,
            state: .init(
                bulletsCount: 1,
                isReloading: false
            )
        )
        // テスト用のデータをセット
        gameViewModel.setCurrentWeapon(currentWeapon)
                
        var outputEventReceivedValues: [GameViewModel.OutputEventType] = []
        
        gameViewModel.outputEvent
            .sink { outputEventReceivedValues.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 1)
        XCTAssertEqual(outputEventReceivedValues, [])
        
        // テスト対象のメソッドを実行
        gameViewModel.fireMotionDetected()
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [
            .arControllerInputEvent(.renderWeaponFiring),
            .playSound(.bazookaFire),
            .executeAutoReload
        ])
    }
    
    func test_fireMotionDetected_残弾数＝0_リロード中＝false_リロードタイプ＝autoの時() {
        let currentWeapon = CurrentWeapon(
            weapon: testData.bazooka,
            state: .init(
                bulletsCount: 0,
                isReloading: false
            )
        )
        // テスト用のデータをセット
        gameViewModel.setCurrentWeapon(currentWeapon)
                
        var outputEventReceivedValues: [GameViewModel.OutputEventType] = []
        
        gameViewModel.outputEvent
            .sink { outputEventReceivedValues.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [])

        // テスト対象のメソッドを実行
        gameViewModel.fireMotionDetected()
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [])
    }
    
    func test_fireMotionDetected_残弾数＝0_リロード中＝true_リロードタイプ＝autoの時() {
        let currentWeapon = CurrentWeapon(
            weapon: testData.bazooka,
            state: .init(
                bulletsCount: 0,
                isReloading: true
            )
        )
        // テスト用のデータをセット
        gameViewModel.setCurrentWeapon(currentWeapon)
                
        var outputEventReceivedValues: [GameViewModel.OutputEventType] = []
        
        gameViewModel.outputEvent
            .sink { outputEventReceivedValues.append($0) }
            .store(in: &cancellables)
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [])

        // テスト対象のメソッドを実行
        gameViewModel.fireMotionDetected()
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
        XCTAssertEqual(outputEventReceivedValues, [])
    }
}
