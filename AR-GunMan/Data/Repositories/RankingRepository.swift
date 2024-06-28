//
//  RankingRepository.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/6/24.
//

import RxSwift

protocol RankingRepositoryInterface {
    func getRanking() -> Single<[Ranking]>
    func registerRanking(_ ranking: Ranking) -> Single<Void>
}

final class RankingRepository: RankingRepositoryInterface {
    private let apiRequestor: APIRequestor<Ranking>
    
    init(apiRequestor: APIRequestor<Ranking>) {
        self.apiRequestor = apiRequestor
    }
    
    func getRanking() -> Single<[Ranking]> {
        return apiRequestor.getItems(
            FirebaseConst.rankingListCollectionName
        )
    }
    
    func registerRanking(_ ranking: Ranking) -> Single<Void> {
        return apiRequestor.postItem(
            FirebaseConst.rankingListCollectionName,
            parameters: ranking.toJson()
        )
    }
}
