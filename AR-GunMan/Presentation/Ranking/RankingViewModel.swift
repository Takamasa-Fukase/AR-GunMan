//
//  RankingViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/12/24.
//

import Foundation
import Observation
import Combine
import Domain
import FirebaseFirestore

@Observable
final class RankingViewModel {
    private(set) var rankingList: [Ranking] = []
    
    let dismiss = PassthroughSubject<Void, Never>()
    
    private let rankingRepository: RankingRepositoryInterface
    
    init(rankingRepository: RankingRepositoryInterface) {
        self.rankingRepository = rankingRepository
    }
    
    func onViewAppear() {
        Task {
            await getRankingAndUpdate()
        }
    }
    
    func closeButtonTapped() {
        dismiss.send(())
    }
    
    private func getRankingAndUpdate() async {
        do {
//            rankingList = try await rankingRepository.getRanking()
            rankingList = try await getRanking()
            
        } catch {
            print("getRanking error: \(error)")
        }
    }
    
    private func getRanking() async throws -> [Ranking] {
        let firestoreDB = Firestore.firestore()
        let docs = try await firestoreDB.collection("worldRanking").getDocuments().documents
        let rankings = docs.compactMap { queryDocSnapshot in
            return try? queryDocSnapshot.data(as: Ranking.self)
        }
        // スコアの高い順にソート
        return rankings.sorted(by: { $0.score > $1.score })
    }
}
