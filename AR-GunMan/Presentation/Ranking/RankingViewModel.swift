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
    enum OutputEventType {
        case dismiss
    }
    
    private(set) var rankingList: [Ranking] = []
    var isLoading = false
    var error: (error: Error?, isAlertPresented: Bool) = (nil, false)
    
    let outputEvent = PassthroughSubject<OutputEventType, Never>()

    private let rankingUseCase: RankingUseCaseInterface

    init(rankingUseCase: RankingUseCaseInterface) {
        self.rankingUseCase = rankingUseCase
    }
    
    func onViewAppear() {
        Task {
            await getRankingAndUpdate()
        }
    }
    
    func closeButtonTapped() {
        outputEvent.send(.dismiss)
    }
    
    private func getRankingAndUpdate() async {
        isLoading = true
        do {
            rankingList = try await rankingUseCase.getSortedRanking()
            
        } catch {
            self.error = (error: error, isAlertPresented: true)
        }
        isLoading = false
    }
}
