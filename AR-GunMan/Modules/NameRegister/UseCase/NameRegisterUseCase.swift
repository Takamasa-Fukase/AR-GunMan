//
//  NameRegisterUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/20.
//

import RxSwift

protocol NameRegisterUseCaseInterface {
    func registerRanking(_ ranking: Ranking) -> Single<Ranking>
}

final class NameRegisterUseCase: NameRegisterUseCaseInterface {
    private let rankingRepository: RankingRepositoryInterface
    
    init(rankingRepository: RankingRepositoryInterface) {
        self.rankingRepository = rankingRepository
    }
    
    func registerRanking(_ ranking: Ranking) -> Single<Ranking> {
        return rankingRepository.registerRanking(ranking)
    }
}
