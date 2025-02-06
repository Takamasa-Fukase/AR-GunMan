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

@Observable
final class NameRegisterViewModel {
    enum OutputEventType {
        case notifyRegistrationCompletion(Ranking)
        case dismiss
    }
    
    let score: Double
    private(set) var temporaryRankText = ""
    private(set) var isRegistering = false
    private(set) var isRegisterButtonEnabled = false
    var error: (error: Error?, isAlertPresented: Bool) = (nil, false)
    var nameText = "" {
        didSet {
            isRegisterButtonEnabled = !nameText.isEmpty
        }
    }
    
    let outputEvent = PassthroughSubject<OutputEventType, Never>()
    
    private let rankingUseCase: RankingUseCaseInterface
    private var cancellables = Set<AnyCancellable>()
    
    init(
        rankingUseCase: RankingUseCaseInterface,
        score: Double,
        temporaryRankTextSubject: CurrentValueSubject<String, Never>
    ) {
        self.rankingUseCase = rankingUseCase
        self.score = score
        
        temporaryRankTextSubject
            .sink { [weak self] rankText in
                self?.temporaryRankText = rankText
            }
            .store(in: &cancellables)
    }
    
    func registerButtonTapped() {
        Task {
            let ranking = Ranking(score: score, userName: nameText)
            
            isRegistering = true
            do {
                try await rankingUseCase.registerRanking(ranking)
                outputEvent.send(.notifyRegistrationCompletion(ranking))
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
