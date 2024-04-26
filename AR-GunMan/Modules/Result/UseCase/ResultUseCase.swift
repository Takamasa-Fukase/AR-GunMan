//
//  ResultUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/18.
//

import RxSwift

final class ResultUseCase {
    private let rankingRepository: RankingRepositoryInterface
    private let replayRepository: ReplayRepositoryInterface
    
    init(
        rankingRepository: RankingRepositoryInterface,
        replayRepository: ReplayRepositoryInterface
    ) {
        self.rankingRepository = rankingRepository
        self.replayRepository = replayRepository
    }
    
    func getRanking() -> Single<[Ranking]> {
        return rankingRepository.getRanking()
    }
    
    func setNeedsReplay(_ newValue: Bool) {
        return replayRepository.setNeedsReplay(newValue)
    }
}
