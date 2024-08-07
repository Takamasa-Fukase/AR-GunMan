//
//  RankingRepository.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/6/24.
//

import RxSwift

final class RankingRepository: RankingRepositoryInterface {
    private let apiRequestor: APIRequestor<Ranking>
    
    init(apiRequestor: APIRequestor<Ranking>) {
        self.apiRequestor = apiRequestor
    }
    
    func getRanking() -> Single<[Ranking]> {
        return apiRequestor.getItems(APIConst.WORLD_RANKING)
    }
    
    func registerRanking(_ ranking: Ranking) -> Single<Void> {
        return apiRequestor.postItem(APIConst.WORLD_RANKING,
                                     parameters: ranking.toJson())
    }
}
