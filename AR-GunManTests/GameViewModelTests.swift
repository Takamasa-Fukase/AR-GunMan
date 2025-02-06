//
//  GameViewModelTests.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 5/2/25.
//

import XCTest
import Domain
@testable import AR_GunMan_Dev

final class GameViewModelTests: XCTestCase {
    private var gameViewModel: GameViewModel!
    private let testData = GameViewModelTestsTestData()
    
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
    
    
    /*
     テストしたいパターン一覧
     - 残弾数 = 1以上, リロード中 = false, リロードタイプ = .manual の時
     - 残弾数 = 1以上, リロード中 = true , リロードタイプ = .manual の時
     - 残弾数 = 0　　, リロード中 = false, リロードタイプ = .manual の時
     - 残弾数 = 0　　, リロード中 = true , リロードタイプ = .manual の時
     - 残弾数 = 1以上, リロード中 = false, リロードタイプ = .auto   の時
     - 残弾数 = 1以上, リロード中 = true , リロードタイプ = .auto   の時
     - 残弾数 = 0　　, リロード中 = false, リロードタイプ = .auto   の時
     - 残弾数 = 0　　, リロード中 = true , リロードタイプ = .auto   の時
     
     テストしたい項目
     <onFiredの処理>
     - bulletsCountが元の残弾数よりも1少ない値になっていること
     - arEventで.renderWeaponFiringが流れてくること
     - playSoundで現在の武器のfiringSoundが流れてくること
     - needsAutoReloadのtrue or falseが期待と合っていること
     - trueの時にreloadWeaponが呼ばれること
     <onOutOfBulletsの処理>
     - 現在の武器に弾切れ音声が存在する場合にplaySoundで弾切れ音声が流れること
     */
    func test_fireMotionDetected() {
        // MARK: 残弾数 = 1以上, リロード中 = false, リロードタイプ = .manual の時
        
        let currentWeapon = CurrentWeapon(
            weapon: testData.pistol,
            state: .init(
                bulletsCount: 1,
                isReloading: false
            )
        )
        gameViewModel.setCurrentWeapon(currentWeapon)
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 1)
        
        gameViewModel.fireMotionDetected()
        
        XCTAssertEqual(gameViewModel.currentWeapon?.state.bulletsCount, 0)
    }
}
