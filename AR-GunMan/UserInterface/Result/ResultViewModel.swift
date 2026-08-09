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
        case scrollToBottom
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
        // 結果画面では毎回まっさらな状態から表示する為、キャッシュをリセットする
        rankingStore.reset()
        
        Task {
            // 0.5秒後に名前登録ダイアログを表示する
            try? await Task.sleep(nanoseconds: 500000000)
            isNameRegisterViewPresented = true
        }
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
    
    func rankingRegistered() {
        guard let ranking = rankingStore.ranking else { return }
        let rankIndex = ranking.getTentativeRankIndex(for: score)
        if rankIndex == (ranking.items.count - 1) {
            // 最下位の場合は新たに増えたindexとなり描画のキャッシュが無い為、
            // 件数の多さによってはスクロールに失敗する可能性が高いので別の表示方法を使用する
            outputEvent.send(.scrollToBottom)
            
        } else {
            outputEvent.send(.scrollCellToCenter(index: rankIndex))
        }
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
}
