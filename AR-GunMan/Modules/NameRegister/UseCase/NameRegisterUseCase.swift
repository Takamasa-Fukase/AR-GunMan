//
//  NameRegisterUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/20.
//

import RxSwift

final class NameRegisterUseCase {
    private let rankingRepository: RankingRepository
    
    init(rankingRepository: RankingRepository) {
        self.rankingRepository = rankingRepository
    }
    
    func registerRanking(_ ranking: Ranking) -> Single<Ranking> {
        return rankingRepository.registerRanking(ranking)
    }
}
