//
//  ResultViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/1/25.
//

import Foundation
import Observation
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
    let outputEvent: AsyncStream<OutputEventType>
    var dataList: [RankingListItemData] {
        return rankingStore.ranking?.items.enumerated().map { (index, item) in
            return item.toRankingListItemData(rankIndex: index)
        } ?? []
    }
    var isNameRegisterViewPresented = false
    var isLoading = false
    var error: (error: Error?, isAlertPresented: Bool) = (nil, false)
        
    private let rankingGetUseCase: RankingGetUseCaseInterface
    private let rankingStore: RankingStoreInterface
    private let outputEventContinuation: AsyncStream<OutputEventType>.Continuation

    init(
        rankingGetUseCase: RankingGetUseCaseInterface,
        rankingStore: RankingStoreInterface,
        score: Double
    ) {
        self.rankingGetUseCase = rankingGetUseCase
        self.rankingStore = rankingStore
        self.score = score
        
        (outputEvent, outputEventContinuation) = AsyncStream.makeStream()
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
            outputEventContinuation.yield(.scrollToBottom)
            
        } else {
            outputEventContinuation.yield(.scrollCellToCenter(index: rankIndex))
        }
    }
    
    func nameRegisterViewClosed() {
        outputEventContinuation.yield(.showButtons)
    }
    
    func replayButtonTapped() {
        outputEventContinuation.yield(.dismissAndNotifyReplayButtonTap)
    }
    
    func toHomeButtonTapped() {
        outputEventContinuation.yield(.notifyHomeButtonTap)
    }
}
