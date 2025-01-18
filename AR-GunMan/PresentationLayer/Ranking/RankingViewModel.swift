//
//  RankingViewModel.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 25/12/24.
//

import Foundation
import Observation
import Combine
import DomainLayer

@Observable
final class RankingViewModel {
    private(set) var rankingList: [Ranking] = []
    
    let dismiss = PassthroughSubject<Void, Never>()
    
    private let rankingRepository: RankingRepositoryInterface
    
    init(rankingRepository: RankingRepositoryInterface) {
        self.rankingRepository = rankingRepository
    }
    
    func getRanking() async {
        do {
            rankingList = try await rankingRepository.getRanking()
            
        } catch {
            print("getRanking error: \(error)")
        }
    }
    
    func closeButtonTapped() {
        dismiss.send(())
    }
}
