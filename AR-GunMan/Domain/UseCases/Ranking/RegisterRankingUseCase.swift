//
//  RegisterRankingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/6/24.
//

import RxSwift
import RxCocoa

struct RegisterRankingInput {
    let ranking: RankingListItemModel
}

struct RegisterRankingOutput {
    let registered: Single<Void>
}

protocol RegisterRankingUseCaseInterface {
    func generateOutput(from input: RegisterRankingInput) -> RegisterRankingOutput
}

final class RegisterRankingUseCase: RegisterRankingUseCaseInterface {
    private let rankingRepository: RankingRepositoryInterface
    
    init(rankingRepository: RankingRepositoryInterface) {
        self.rankingRepository = rankingRepository
    }
    
    func generateOutput(from input: RegisterRankingInput) -> RegisterRankingOutput {
        // Entityに変換
        let ranking = Ranking(
            score: input.ranking.score,
            userName: input.ranking.userName
        )
        let registered = rankingRepository.registerRanking(ranking)
        return RegisterRankingOutput(
            registered: registered
        )
    }
}
