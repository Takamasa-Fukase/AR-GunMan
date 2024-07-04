//
//  GetRankingUseCaseTests_with_expectation.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 4/7/24.
//

import XCTest
import RxSwift
@testable import AR_GunMan

/// RxBlockingもRxTestも使わずにXCTestデフォルトのexpectationのみでの書き方

final class GetRankingUseCaseTests_with_expectation: XCTestCase {
    var disposeBag: DisposeBag!
    var rankingRepository: MockRankingRepository!
    var getRankingUseCase: GetRankingUseCase!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        rankingRepository = MockRankingRepository()
        rankingRepository.responseDelayTime = .milliseconds(1500)
        getRankingUseCase = GetRankingUseCase(rankingRepository: rankingRepository)
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        rankingRepository = nil
        getRankingUseCase = nil
    }

    func test_スコアの高い順にソートされたItemModelのリストが出力されれば成功() {
        let expectation = expectation(description: "test_スコアの高い順にソートされたItemModelのリストが出力されれば成功")
        
        let dummyRankingList: [Ranking] = [
            Ranking(score: 50.777, userName: "ユーザー1"),
            Ranking(score: 50.778, userName: "ユーザー2"),
            Ranking(score: 75.000, userName: "ユーザー3"),
            Ranking(score:  0.000, userName: "ユーザー4"),
            Ranking(score: 100.00, userName: "ユーザー5"),
            Ranking(score:  3.999, userName: "ユーザー6")
        ]
        rankingRepository.getRankingResponse = Single.just(dummyRankingList)
        
        let expectedSortedResponse = [
            RankingListItemModel(score: 100.00, userName: "ユーザー5"),
            RankingListItemModel(score: 75.000, userName: "ユーザー3"),
            RankingListItemModel(score: 50.778, userName: "ユーザー2"),
            RankingListItemModel(score: 50.777, userName: "ユーザー1"),
            RankingListItemModel(score:  3.999, userName: "ユーザー6"),
            RankingListItemModel(score:  0.000, userName: "ユーザー4")
        ]
        
        var response: [RankingListItemModel]?
        
        disposeBag.insert {
            getRankingUseCase.generateOutput().rankingList
                .subscribe(
                    onSuccess: { list in
                        response = list
                        XCTAssertEqual(response, expectedSortedResponse)
                        expectation.fulfill()
                    },
                    onFailure: { _ in
                        XCTFail()
                    }
                )
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func test_流したエラーを受け取れば成功() {
        let expectation = expectation(description: "test_例外が発生せずに完了すれば成功")
        
        rankingRepository.getRankingResponse = Single.error(CustomError.manualError("テストエラー"))
             
        disposeBag.insert {
            getRankingUseCase.generateOutput().rankingList
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
