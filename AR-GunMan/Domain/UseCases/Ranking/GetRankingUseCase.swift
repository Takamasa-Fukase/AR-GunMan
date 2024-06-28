//
//  GetRankingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/6/24.
//

import RxSwift

struct RankingListItemModel {
    let score: Double
    let userName: String
}

struct GetRankingOutput {
    let rankingList: Single<[RankingListItemModel]>
}

protocol GetRankingUseCaseInterface {
    func execute() -> GetRankingOutput
}

final class GetRankingUseCase: GetRankingUseCaseInterface {
    private let rankingRepository: RankingRepositoryInterface
    
    init(rankingRepository: RankingRepositoryInterface) {
        self.rankingRepository = rankingRepository
    }
    
    func execute() -> GetRankingOutput {
        let sortedRankingList = rankingRepository.getRanking()
            .map({ rankingList in
                // スコアの高い順にソート
                let sortedList = rankingList.sorted(by: { $0.score > $1.score })
                // Presentation層用のデータモデルに変換
                let listItemModels = sortedList.map({
                    return RankingListItemModel(score: $0.score, userName: $0.userName)
                })
                return listItemModels
            })
        return GetRankingOutput(
            rankingList: sortedRankingList
        )
    }
}
