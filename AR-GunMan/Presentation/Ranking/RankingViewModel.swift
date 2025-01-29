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
            let rankingList = try await rankingRepository.getRanking()
            // スコアの高い順にソートして代入
            self.rankingList = rankingList.sorted(by: { $0.score > $1.score })
            
        } catch {
            print("getRanking error: \(error)")
        }
    }
}
