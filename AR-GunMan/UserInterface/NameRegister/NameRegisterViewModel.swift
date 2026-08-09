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
        case notifyRegistrationCompletion
        case dismiss
    }
    
    let score: Double
    var temporaryRankText: String {
        guard let temporaryRankIndex = rankingStore.ranking?.getTentativeRankIndex(for: score),
              let itemsCount = rankingStore.ranking?.items.count else {
            return ""
        }
        return "\(temporaryRankIndex + 1) / \(itemsCount)"
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
    private var cancellables = Set<AnyCancellable>()
    
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
                outputEvent.send(.notifyRegistrationCompletion)
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
