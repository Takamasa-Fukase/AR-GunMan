//
//  RankingRepository.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 10/1/25.
//

import Foundation
import Domain

final class RankingRepository: RankingRepositoryInterface {
    private let firestoreClient: FirestoreClient
    
    init(firestoreClient: FirestoreClient) {
        self.firestoreClient = firestoreClient
    }
    
    func getRanking() async throws -> [Ranking] {
        return try await firestoreClient
            .getItems(collectionPath: APIConst.WORLD_RANKING)
    }
    
    func registerRanking(_ ranking: Ranking) async throws {
        try await firestoreClient
            .addItem(
                collectionPath: APIConst.WORLD_RANKING,
                requestEntity: ranking
            )
    }
}
