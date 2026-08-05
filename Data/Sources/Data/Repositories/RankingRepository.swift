//
//  RankingRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 10/1/25.
//

import Foundation
import Domain

@MainActor
public final class RankingRepository: RankingRepositoryInterface {
    private let firestoreClient: FirestoreClientInterface
    private var rankingStore: RankingStoreInterface
    
    public var items: [RankingItem]? {
        return rankingStore.ranking?.items
    }
    
    public init(
        firestoreClient: FirestoreClientInterface,
        rankingStore: RankingStoreInterface
    ) {
        self.firestoreClient = firestoreClient
        self.rankingStore = rankingStore
    }

    public func getRankingItems() async throws {
        let rankingItems: [RankingItem] = try await firestoreClient
            .getItems(collectionPath: FirestoreConst.WORLD_RANKING)
        rankingStore.ranking = Ranking(items: rankingItems)
    }
    
    public func getTentativeRankIndex(for score: Double) -> Int {
        return rankingStore.ranking?.getTentativeRankIndex(for: score) ?? 0
    }
    
    public func registerRankingItem(_ item: RankingItem) async throws {
        try await firestoreClient
            .addItem(
                collectionPath: FirestoreConst.WORLD_RANKING,
                requestEntity: item
            )
    }
    
    public func insertRegisteredRanking(
        at index: Int,
        item: RankingItem
    ) {
        rankingStore.ranking?.insertRegisteredRanking(at: index, item: item)
    }
}
