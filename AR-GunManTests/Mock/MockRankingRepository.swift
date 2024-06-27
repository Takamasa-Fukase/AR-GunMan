//
//  MockRankingRepository.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/6/24.
//

import RxSwift

final class MockRankingRepository: RankingRepositoryInterface {
    private let scheduler: SchedulerType
    
    init(scheduler: SchedulerType = MainScheduler.instance) {
        self.scheduler = scheduler
    }
    
    func getRanking() -> Single<[Ranking]> {
        let dummyRankingList = Array<Int>(1...100).map({ index in
            return Ranking(score: Double(101 - index), userName: "ダミーユーザー\(index)")
        })
        return Single
            .just(dummyRankingList)
            .delay(.milliseconds(1500), scheduler: scheduler)
    }
    
    func registerRanking(_ ranking: Ranking) -> Single<Ranking> {
        return Single
            .just(ranking)
            .delay(.milliseconds(1500), scheduler: scheduler)
    }
}
