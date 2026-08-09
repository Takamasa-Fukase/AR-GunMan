//
//  RankingRegisterUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/08/09.
//

import Foundation

@MainActor
public protocol RankingRegisterUseCaseInterface {
    func execute(item: RankingItem) async throws
}

@MainActor
public final class RankingRegisterUseCase: RankingRegisterUseCaseInterface {
    private let rankingRepository: RankingRepositoryInterface
    private var rankingStore: RankingStoreInterface
    
    public init(
        rankingRepository: RankingRepositoryInterface,
        rankingStore: RankingStoreInterface
    ) {
        self.rankingRepository = rankingRepository
        self.rankingStore = rankingStore
    }
    
    public func execute(item: RankingItem) async throws {
        try await rankingRepository.registerItem(item)
        rankingStore.ranking?.insertRegisteredRanking(item: item)
    }
}
