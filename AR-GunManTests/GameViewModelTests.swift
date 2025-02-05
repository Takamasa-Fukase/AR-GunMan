//
//  GameViewModelTests.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 5/2/25.
//

import XCTest
@testable import AR_GunMan_Dev

final class GameViewModelTests: XCTestCase {
    private var gameViewModel: GameViewModel!
    
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
    
    func test_example() {
        XCTAssertEqual(gameViewModel.score, 0.0)
    }
}
