//
//  ResultUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/18.
//

import RxSwift

protocol ResultUseCaseInterface {
    func getRanking() -> Single<[Ranking]>
    func setNeedsReplay(_ newValue: Bool)
}

final class ResultUseCase: ResultUseCaseInterface {
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
