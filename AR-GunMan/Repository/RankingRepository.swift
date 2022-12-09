//
//  RankingRepository.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/31.
//

import Foundation
import Firebase
import RxSwift

class RankingRepository {
    private static let firestoreDataBase = Firestore.firestore()
    
    static func getRanking() async -> [Ranking]? {
        do {
            let snapshot = try await firestoreDataBase
                .collection("worldRanking")
                .order(by: "score", descending: true)
                .getDocuments()
            return snapshot.documents.map { data -> Ranking in
                return Ranking(score: data.data()["score"] as? Double ?? 0.000,
                               userName: data.data()["user_name"] as? String ?? "NO NAME")
            }
            
        } catch {
            print("RankingRepository.getRanking_error: \(error)")
            return nil
        }
    }
}
