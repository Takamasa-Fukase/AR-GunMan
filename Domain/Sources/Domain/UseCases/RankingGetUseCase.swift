//
//  RankingGetUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/08/09.
//

import Foundation

@MainActor
public protocol RankingGetUseCaseInterface {
    func execute() async throws
}

@MainActor
public final class RankingGetUseCase: RankingGetUseCaseInterface {
    private let rankingRepository: RankingRepositoryInterface
    private var rankingStore: RankingStoreInterface
    
    public init(
        rankingRepository: RankingRepositoryInterface,
        rankingStore: RankingStoreInterface
    ) {
        self.rankingRepository = rankingRepository
        self.rankingStore = rankingStore
    }
    
    public func execute() async throws {
        let items = try await rankingRepository.getItems()
        rankingStore.ranking = Ranking(items: items)
    }
}
