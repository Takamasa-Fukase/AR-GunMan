//
//  RankingRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 10/1/25.
//

import Foundation
import Domain

public final class RankingRepository: RankingRepositoryInterface {
    private let firestoreClient: FirestoreClientInterface
    
    public init(firestoreClient: FirestoreClientInterface) {
        self.firestoreClient = firestoreClient
    }
    
    public func getRanking() async throws -> [Ranking] {
        return try await firestoreClient
            .getItems(collectionPath: FirestoreConst.WORLD_RANKING)
    }
    
    public func registerRanking(_ ranking: Ranking) async throws {
        try await firestoreClient
            .addItem(
                collectionPath: FirestoreConst.WORLD_RANKING,
                requestEntity: ranking
            )
    }
}
