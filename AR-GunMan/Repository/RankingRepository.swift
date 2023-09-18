//
//  RankingRepository.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/31.
//

import Foundation
import Firebase
import RxSwift
import FirebaseFirestoreSwift

class RankingRepository {
    private let firestoreDataBase = Firestore.firestore()
    
    func getRanking() async throws -> [Ranking] {
        return try await firestoreDataBase
            .collection("worldRanking")
            .order(by: "score", descending: true)
            .getDocuments()
            .documents
            .compactMap({ queryDocSnapshot in
                return try? queryDocSnapshot.data(as: Ranking.self)
            })
    }
    
    func registerRanking(_ ranking: Ranking) throws {
        try firestoreDataBase
            .collection("worldRanking")
            .document()
            .setData(from: ranking)
    }
}
