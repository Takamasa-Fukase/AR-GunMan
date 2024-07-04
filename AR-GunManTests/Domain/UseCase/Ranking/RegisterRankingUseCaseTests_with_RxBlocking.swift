//
//  RegisterRankingUseCaseTests_with_RxBlocking.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 4/7/24.
//

import XCTest
import RxBlocking
import RxSwift
@testable import AR_GunMan

final class RegisterRankingUseCaseTests_with_RxBlocking: XCTestCase {
    var rankingRepository: MockRankingRepository!
    var registerRankingUseCase: RegisterRankingUseCase!
    
    override func setUp() {
        super.setUp()
        rankingRepository = MockRankingRepository()
        registerRankingUseCase = RegisterRankingUseCase(rankingRepository: rankingRepository)
    }
    
    override func tearDown() {
        super.tearDown()
        rankingRepository = nil
        registerRankingUseCase = nil
    }
    
    func test_例外が発生せずに完了すれば成功() {
        rankingRepository.registerRankingResponse = Single.just(())
        
        let dummyRanking = RankingListItemModel(score: 100.00, userName: "テストユーザー1")
        let input = RegisterRankingInput(ranking: dummyRanking)
        
        XCTAssertNoThrow(try registerRankingUseCase.generateOutput(from: input).registered.toBlocking().single())
    }
    
    func test_流したエラーを受け取れば成功() {
        rankingRepository.registerRankingResponse = Single.error(CustomError.manualError("テストエラー"))
        
        let dummyRanking = RankingListItemModel(score: 100.00, userName: "テストユーザー1")
        let input = RegisterRankingInput(ranking: dummyRanking)
        
        XCTAssertThrowsError(try registerRankingUseCase.generateOutput(from: input).registered.toBlocking().single()) { error in
            guard let customError = error as? CustomError,
                  case .manualError(let message) = customError else {
                XCTFail("エラーの種別が期待していたCustomErrorではないため、テストを失敗させました。")
                return
            }
            XCTAssertEqual(message, "テストエラー")
        }
    }
}
