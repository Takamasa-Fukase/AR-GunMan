//
//  GetRankingUseCaseTests_with_RxTest.swift
//  AR-GunManTests
//
//  Created by ウルトラ深瀬 on 4/7/24.
//

import XCTest
import RxTest
import RxSwift
@testable import AR_GunMan

/// RxBlockingを使わずにRxTestのみでの書き方

final class GetRankingUseCaseTests_with_RxTest: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var rankingRepository: MockRankingRepository!
    var getRankingUseCase: GetRankingUseCase!
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(
            initialClock: 0,
            // 仮想時間をmillisecondsにする
            resolution: 0.001
        )
        disposeBag = DisposeBag()
        rankingRepository = MockRankingRepository(scheduler: scheduler)
        rankingRepository.responseDelayTime = .milliseconds(1500)
        getRankingUseCase = GetRankingUseCase(rankingRepository: rankingRepository)
    }
    
    override func tearDown() {
        super.tearDown()
        scheduler = nil
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
        
        // MEMO: Singleの場合はTestableObserverが対応していないのでObservableに変換する必要がある模様
        let rankingListResponse = getRankingUseCase.generateOutput().rankingList.asObservable()
        let observer = scheduler.createObserver([RankingListItemModel].self)
        
        disposeBag.insert {
            rankingListResponse
                .subscribe(observer)
        }
        
        scheduler.start()
        
        let expectedSortedResponse = [
            RankingListItemModel(score: 100.00, userName: "ユーザー5"),
            RankingListItemModel(score: 75.000, userName: "ユーザー3"),
            RankingListItemModel(score: 50.778, userName: "ユーザー2"),
            RankingListItemModel(score: 50.777, userName: "ユーザー1"),
            RankingListItemModel(score:  3.999, userName: "ユーザー6"),
            RankingListItemModel(score:  0.000, userName: "ユーザー4")
        ]
        
        let expectedEvents: [Recorded] = [
            .next(1500, expectedSortedResponse),
            .completed(1501)
        ]
        
        XCTAssertEqual(observer.events, expectedEvents)
    }
    
    func test_流したエラーを受け取れば成功() {
        rankingRepository.getRankingResponse = Single.error(CustomError.manualError("テストエラー"))
        
        // MEMO: Singleの場合はTestableObserverが対応していないのでObservableに変換する必要がある模様
        let rankingListResponse = getRankingUseCase.generateOutput().rankingList.asObservable()
        let observer = scheduler.createObserver([RankingListItemModel].self)
        
        disposeBag.insert {
            rankingListResponse
                .subscribe(observer)
        }
        
        scheduler.start()
        
        let expectedEvents: [Recorded<Event<[RankingListItemModel]>>] = [
            // MEMO: MockRepositoryのレスポンスを.delayさせてもエラーの場合は即時流れるので0を指定
            .error(0, CustomError.manualError("テストエラー"))
        ]
        
        XCTAssertEqual(observer.events, expectedEvents)
    }
}
