//
//  ResultViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/1/25.
//

import Foundation
import Observation
import Combine
import Domain

@MainActor
@Observable
final class ResultViewModel {
    enum OutputEventType {
        case showButtons
        case dismissAndNotifyReplayButtonTap
        case notifyHomeButtonTap
        case scrollCellToCenter(index: Int)
    }
    
    let score: Double
    var dataList: [RankingListItemData] {
        return rankingStore.ranking?.items.enumerated().map { (index, item) in
            return item.toRankingListItemData(rankIndex: index)
        } ?? []
    }
    var isNameRegisterViewPresented = false
    var isLoading = false
    var error: (error: Error?, isAlertPresented: Bool) = (nil, false)
    
    let outputEvent = PassthroughSubject<OutputEventType, Never>()
    
    private let rankingGetUseCase: RankingGetUseCaseInterface
    private let rankingStore: RankingStoreInterface
    
    init(
        rankingGetUseCase: RankingGetUseCaseInterface,
        rankingStore: RankingStoreInterface,
        score: Double
    ) {
        self.rankingGetUseCase = rankingGetUseCase
        self.rankingStore = rankingStore
        self.score = score
    }
    
    func onViewAppear() {
        executeSimultaneously()
    }
    
    func rankingRegistered() {
        guard let rankIndex = rankingStore.ranking?.getTentativeRankIndex(for: score) else {
            return
        }
        outputEvent.send(.scrollCellToCenter(index: rankIndex))
    }
    
    func nameRegisterViewClosed() {
        outputEvent.send(.showButtons)
    }
    
    func replayButtonTapped() {
        outputEvent.send(.dismissAndNotifyReplayButtonTap)
    }
    
    func toHomeButtonTapped() {
        outputEvent.send(.notifyHomeButtonTap)
    }
    
    private func executeSimultaneously() {
        Task {
            do {
                // 0.5秒後に名前登録ダイアログを表示する
                try await Task.sleep(nanoseconds: 500000000)
                self.isNameRegisterViewPresented = true
                
            } catch {
                self.error = (error: error, isAlertPresented: true)
            }
        }
        Task {
            self.isLoading = true
            do {
                try await self.rankingGetUseCase.execute()

            } catch {
                self.error = (error: error, isAlertPresented: true)
            }
            self.isLoading = false
        }
    }
}
