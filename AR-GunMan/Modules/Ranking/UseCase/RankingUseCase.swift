//
//  RankingUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/23.
//

import RxSwift

protocol RankingUseCaseInterface {
    func getRanking() -> Single<[Ranking]>
}

final class RankingUseCase: RankingUseCaseInterface {
    private let rankingRepository: RankingRepositoryInterface
    
    init(rankingRepository: RankingRepositoryInterface) {
        self.rankingRepository = rankingRepository
    }
    
    func getRanking() -> Single<[Ranking]> {
        return rankingRepository.getRanking()
    }
}
