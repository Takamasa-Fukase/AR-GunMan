//
//  NameRegisterViewModel.swift
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
final class NameRegisterViewModel {
    enum OutputEventType {
        case notifyRegistered
        case dismiss
    }
    
    let score: Double
    var temporaryRankText: String? {
        guard let ranking = rankingStore.ranking else {
            // ランキング取得中の場合はrankingがnilなのでnilを返す
            return nil
        }
        // 今回のscoreで仮に登録した場合の順位
        let temporaryRank = ranking.getTentativeRankIndex(for: score) + 1
        // 登録済みランキング数に今回の結果を加えた数
        let totalCount = ranking.items.count + 1
        return "\(temporaryRank) / \(totalCount)"
    }
    private(set) var isRegistering = false
    private(set) var isRegisterButtonEnabled = false
    var error: (error: Error?, isAlertPresented: Bool) = (nil, false)
    var nameText = "" {
        didSet {
            isRegisterButtonEnabled = !nameText.isEmpty
        }
    }
    
    let outputEvent = PassthroughSubject<OutputEventType, Never>()
    
    private let rankingRegisterUseCase: RankingRegisterUseCaseInterface
    private let rankingStore: RankingStoreInterface
    
    init(
        rankingRegisterUseCase: RankingRegisterUseCaseInterface,
        rankingStore: RankingStoreInterface,
        score: Double
    ) {
        self.rankingRegisterUseCase = rankingRegisterUseCase
        self.rankingStore = rankingStore
        self.score = score
    }
    
    func registerButtonTapped() {
        Task {
            let item = RankingItem(score: score, userName: nameText)
            
            isRegistering = true
            do {
                try await rankingRegisterUseCase.execute(item: item)
                outputEvent.send(.notifyRegistered)
                outputEvent.send(.dismiss)
                
            } catch {
                self.error = (error: error, isAlertPresented: true)
            }
            isRegistering = false
        }
    }
    
    func noButtonTapped() {
        outputEvent.send(.dismiss)
    }
}
