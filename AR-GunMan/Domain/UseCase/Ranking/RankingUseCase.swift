//
//  RankingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/6/24.
//

import RxSwift

struct GetRankingOutput {
    let rankingList: Single<[Ranking]>
}

protocol GetRankingUseCaseInterface {
    func execute() -> GetRankingOutput
}

final class GetRankingUseCase: GetRankingUseCaseInterface {
    private let rankingRepository: RankingRepositoryInterface2
    
    init(rankingRepository: RankingRepositoryInterface2) {
        self.rankingRepository = rankingRepository
    }
    
    func execute() -> GetRankingOutput {
        let sortedRankingList = rankingRepository.getRanking()
            .map({ rankingList in
                return rankingList.sorted(by: { $0.score > $1.score })
            })
        return GetRankingOutput(
            rankingList: sortedRankingList
        )
    }
}
