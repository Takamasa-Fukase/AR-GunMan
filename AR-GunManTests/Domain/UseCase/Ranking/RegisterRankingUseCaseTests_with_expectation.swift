//
//  RegisterRankingUseCaseTests_with_expectation.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 4/7/24.
//

import XCTest
import RxSwift
@testable import AR_GunMan

/// RxBlockingもRxTestも使わずにXCTestデフォルトのexpectationのみでの書き方

final class RegisterRankingUseCaseTests_with_expectation: XCTestCase {
    var disposeBag: DisposeBag!
    var rankingRepository: MockRankingRepository!
    var registerRankingUseCase: RegisterRankingUseCase!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        rankingRepository = MockRankingRepository()
        registerRankingUseCase = RegisterRankingUseCase(rankingRepository: rankingRepository)
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        rankingRepository = nil
        registerRankingUseCase = nil
    }
    
    func test_例外が発生せずに成功レスポンスを受け取れば成功() {
        let expectation = expectation(description: "test_例外が発生せずに成功レスポンスを受け取れば成功")
        
        rankingRepository.registerRankingResponse = Single.just(())
        
        let dummyRanking = RankingListItemModel(score: 100.00, userName: "テストユーザー1")
        let input = RegisterRankingInput(ranking: dummyRanking)
        
        var isSuccessResponseReceived = false
        
        disposeBag.insert {
            registerRankingUseCase.generateOutput(from: input).registered
                .subscribe(
                    onSuccess: { _ in
                        isSuccessResponseReceived = true
                        XCTAssertTrue(isSuccessResponseReceived)
                        expectation.fulfill()
                    },
                    onFailure: { error in
                        XCTFail()
                    }
                )
            
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func test_流したエラーを受け取れば成功() {
        let expectation = expectation(description: "test_流したエラーを受け取れば成功")
        
        rankingRepository.registerRankingResponse = Single.error(CustomError.manualError("テストエラー"))
        
        let dummyRanking = RankingListItemModel(score: 100.00, userName: "テストユーザー1")
        let input = RegisterRankingInput(ranking: dummyRanking)
                
        disposeBag.insert {
            registerRankingUseCase.generateOutput(from: input).registered
                .subscribe(
                    onSuccess: { _ in
                        XCTFail()
                    },
                    onFailure: { error in
                        guard let customError = error as? CustomError,
                              case .manualError(let message) = customError else {
                            XCTFail("エラーの種別が期待していたCustomErrorではないため、テストを失敗させました。")
                            return
                        }
                        XCTAssertEqual(message, "テストエラー")
                        
                        expectation.fulfill()
                    }
                )
            
        }
        wait(for: [expectation], timeout: 10)
    }
}
