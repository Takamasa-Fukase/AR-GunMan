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
    private let rankingRepository: RankingRepository
    
    init(rankingRepository: RankingRepository) {
        self.rankingRepository = rankingRepository
    }
    
    func getRanking() -> Single<[Ranking]> {
        return rankingRepository.getRanking()
    }
}

final class MockRankingUseCase: RankingUseCaseInterface {
    func getRanking() -> Single<[Ranking]> {
        return Single.create(subscribe: { observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                return observer(.failure(CustomError.manualError("TEST ERROR")))
            })
            return Disposables.create()
        })
    }
}
