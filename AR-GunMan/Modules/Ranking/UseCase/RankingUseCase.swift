//
//  RankingUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/23.
//

import RxSwift

final class RankingUseCase {
    private let rankingRepository: RankingRepository
    
    init(rankingRepository: RankingRepository) {
        self.rankingRepository = rankingRepository
    }
    
    func getRanking() -> Single<[Ranking]> {
        return rankingRepository.getRanking()
    }
}

