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

@MainActor
@Observable
final class RankingViewModel {
    enum OutputEventType {
        case dismiss
    }
    
    var dataList: [RankingListItemData] {
        return rankingStore.ranking?.items.enumerated().map { (index, item) in
            return item.toRankingListItemData(rankIndex: index)
        } ?? []
    }
    var isLoading = false
    var error: (error: Error?, isAlertPresented: Bool) = (nil, false)
    
    let outputEvent = PassthroughSubject<OutputEventType, Never>()

    private let rankingGetUseCase: RankingGetUseCaseInterface
    private let rankingStore: RankingStoreInterface

    init(
        rankingGetUseCase: RankingGetUseCaseInterface,
        rankingStore: RankingStoreInterface
    ) {
        self.rankingGetUseCase = rankingGetUseCase
        self.rankingStore = rankingStore
    }
    
    func onViewAppear() {
        getRanking()
    }
    
    func closeButtonTapped() {
        outputEvent.send(.dismiss)
    }
    
    private func getRanking() {
        Task {
            isLoading = true
            do {
                try await rankingGetUseCase.execute()
                
            } catch {
                self.error = (error: error, isAlertPresented: true)
            }
            isLoading = false
        }
    }
}

extension RankingItem {
    func toRankingListItemData(rankIndex: Int) -> RankingListItemData {
        return RankingListItemData(
            rank: (String(rankIndex + 1)),
            score: score.scoreText,
            userName: userName
        )
    }
}
