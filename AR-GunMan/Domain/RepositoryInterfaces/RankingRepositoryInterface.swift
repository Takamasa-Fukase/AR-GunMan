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
