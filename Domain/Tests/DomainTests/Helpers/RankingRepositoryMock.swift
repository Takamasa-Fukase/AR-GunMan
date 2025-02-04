//
//  RankingRepositoryMock.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 4/2/25.
//

import Domain

final class RankingRepositoryMock: RankingRepositoryInterface {
    var rankingList: [Ranking] = [
        .init(score: 9.000, userName: ""),
        .init(score: 100.00, userName: ""),
        .init(score: 0.000, userName: ""),
        .init(score: 50.000, userName: "")
    ]
    var registeredRanking: Ranking?
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
        registeredRanking = ranking
    }
}
