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
    let score: Double
    private(set) var temporaryRankText = ""
    private(set) var isRegistering = false
    private(set) var isRegisterButtonEnabled = false
    var nameText = "" {
        didSet {
            isRegisterButtonEnabled = !nameText.isEmpty
        }
    }
    
    let notifyRegistrationCompletion = PassthroughSubject<Ranking, Never>()
    let dismiss = PassthroughSubject<Void, Never>()
    
    private let rankingRepository: RankingRepositoryInterface
    private var cancellables = Set<AnyCancellable>()
    
    init(
        rankingRepository: RankingRepositoryInterface,
        score: Double,
        temporaryRankTextSubject: CurrentValueSubject<String, Never>
    ) {
        self.rankingRepository = rankingRepository
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
                try await rankingRepository.registerRanking(ranking)
                notifyRegistrationCompletion.send(ranking)
                dismiss.send(())
                
            } catch {
                print("register error: \(error)")
                // TODO: エラーをアラート表示
            }
            isRegistering = false
        }
    }
    
    func noButtonTapped() {
        dismiss.send(())
    }
}
