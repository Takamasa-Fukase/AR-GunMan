//
//  GetRankingUseCaseTests_with_RxBlocking.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 4/7/24.
//

import XCTest
import RxBlocking
import RxSwift
@testable import AR_GunMan

final class GetRankingUseCaseTests_with_RxBlocking: XCTestCase {
    var disposeBag: DisposeBag!
    var rankingRepository: MockRankingRepository!
    var getRankingUseCase: GetRankingUseCase!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        // MEMO: RxBlockingを使う時はRepositoryでTestSchedulerを使うとテストが終了しないので渡さない
        rankingRepository = MockRankingRepository()
        getRankingUseCase = GetRankingUseCase(rankingRepository: rankingRepository)
    }
    
    override func tearDown() {
        disposeBag = nil
        rankingRepository = nil
        getRankingUseCase = nil
    }

    func test_スコアの高い順にソートされたItemModelのリストが出力されれば成功() {
        let dummyRankingList: [Ranking] = [
            Ranking(score: 50.777, userName: "ユーザー1"),
            Ranking(score: 50.778, userName: "ユーザー2"),
            Ranking(score: 75.000, userName: "ユーザー3"),
            Ranking(score:  0.000, userName: "ユーザー4"),
            Ranking(score: 100.00, userName: "ユーザー5"),
            Ranking(score:  3.999, userName: "ユーザー6")
        ]
        rankingRepository.getRankingResponse = Single.just(dummyRankingList)
        
        let rankingListResponse = try! getRankingUseCase.generateOutput().rankingList.toBlocking().single()
        
        let expectedSortedResponse = [
            RankingListItemModel(score: 100.00, userName: "ユーザー5"),
            RankingListItemModel(score: 75.000, userName: "ユーザー3"),
            RankingListItemModel(score: 50.778, userName: "ユーザー2"),
            RankingListItemModel(score: 50.777, userName: "ユーザー1"),
            RankingListItemModel(score:  3.999, userName: "ユーザー6"),
            RankingListItemModel(score:  0.000, userName: "ユーザー4")
        ]
        
        XCTAssertEqual(rankingListResponse, expectedSortedResponse)
    }
    
    func test_流したエラーを受け取れば成功() {
        rankingRepository.getRankingResponse = Single.error(CustomError.manualError("テストエラー"))
        
        let rankingListResponse = getRankingUseCase.generateOutput().rankingList.toBlocking().materialize()
        
        switch rankingListResponse {
        case .completed:
            XCTFail("エラーが発生するべき箇所で発生しなかったためテストを失敗させました。")
        case .failed(_, let error):
            guard let customError = error as? CustomError,
                  case .manualError(let message) = customError else {
                XCTFail("エラーの種別が期待していたCustomErrorではないため、テストを失敗させました。")
                return
            }
            XCTAssertEqual(message, "テストエラー")
        }
    }
}
