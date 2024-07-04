//
//  MockRankingRepository.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/6/24.
//

import RxSwift

final class MockRankingRepository: RankingRepositoryInterface {
    private let scheduler: SchedulerType
    
    var getRankingResponse = Single.just(
        Array<Int>(1...100).map({ index in
            return Ranking(score: Double(101 - index), userName: "ダミーユーザー\(index)")
        })
    )
    var registerRankingResponse = Single.just(())
    var responseDelayTime: RxTimeInterval = .milliseconds(1500)
    
    init(scheduler: SchedulerType = MainScheduler.instance) {
        self.scheduler = scheduler
    }
    
    func getRanking() -> Single<[Ranking]> {
        return getRankingResponse
            .delay(responseDelayTime, scheduler: scheduler)
    }
    
    func registerRanking(_ ranking: Ranking) -> Single<Void> {
        return registerRankingResponse
            .delay(responseDelayTime, scheduler: scheduler)
    }
}
