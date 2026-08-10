//
//  RankingViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/12/24.
//

import Foundation
import Observation
import Domain
import FirebaseFirestore

@MainActor
@Observable
final class RankingViewModel {
    enum OutputEventType {
        case dismiss
    }
    
    let outputEvent: AsyncStream<OutputEventType>
    var dataList: [RankingListItemData] {
        return rankingStore.ranking?.items.enumerated().map { (index, item) in
            return item.toRankingListItemData(rankIndex: index)
        } ?? []
    }
    var isLoading = false
    var error: (error: Error?, isAlertPresented: Bool) = (nil, false)
    
    private let rankingGetUseCase: RankingGetUseCaseInterface
    private let rankingStore: RankingStoreInterface
    private let outputEventContinuation: AsyncStream<OutputEventType>.Continuation

    init(
        rankingGetUseCase: RankingGetUseCaseInterface,
        rankingStore: RankingStoreInterface
    ) {
        self.rankingGetUseCase = rankingGetUseCase
        self.rankingStore = rankingStore
        
        (outputEvent, outputEventContinuation) = AsyncStream.makeStream()
    }
    
    func onViewAppear() {
        getRanking()
    }
    
    func closeButtonTapped() {
        outputEventContinuation.yield(.dismiss)
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
