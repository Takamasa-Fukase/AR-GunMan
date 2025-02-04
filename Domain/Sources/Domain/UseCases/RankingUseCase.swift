//
//  RankingUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 4/2/25.
//

import Foundation

public protocol RankingUseCaseInterface {
    func getSortedRanking() async throws -> [Ranking]
    func registerRanking(_ ranking: Ranking) async throws
}

public final class RankingUseCase: RankingUseCaseInterface {
    private let rankingRepository: RankingRepositoryInterface
    
    public init(rankingRepository: RankingRepositoryInterface) {
        self.rankingRepository = rankingRepository
    }
    
    public func getSortedRanking() async throws -> [Ranking] {
        return try await rankingRepository
            .getRanking()
            .sorted { $0.score > $1.score } // スコアの高い順にソート
    }
    
    public func registerRanking(_ ranking: Ranking) async throws {
        try await rankingRepository.registerRanking(ranking)
    }
}
