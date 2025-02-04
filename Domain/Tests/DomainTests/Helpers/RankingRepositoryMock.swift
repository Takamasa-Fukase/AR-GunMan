//
//  RankingRepositoryMock.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 4/2/25.
//

import Domain

final class RankingRepositoryMock: RankingRepositoryInterface {
    var rankingList: [Ranking] = []
    var error: Error?
    
    func getRanking() async throws -> [Ranking] {
        if let error = error {
            throw error
        }
        return rankingList
    }
    
    func registerRanking(_ ranking: Ranking) async throws {
        if let error = error {
            throw error
        }
        rankingList.append(ranking)
    }
}
