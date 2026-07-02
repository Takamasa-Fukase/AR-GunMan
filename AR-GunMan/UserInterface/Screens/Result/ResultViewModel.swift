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

@Observable
final class ResultViewModel {
    enum OutputEventType {
        case showButtons
        case dismissAndNotifyReplayButtonTap
        case notifyHomeButtonTap
        case scrollCellToCenter(index: Int)
    }
    
    let score: Double
    private(set) var rankingList: [Ranking] = []
    var isNameRegisterViewPresented = false
    var isLoading = false
    var error: (error: Error?, isAlertPresented: Bool) = (nil, false)
    
    let outputEvent = PassthroughSubject<OutputEventType, Never>()
    let temporaryRankTextSubject = CurrentValueSubject<String, Never>("")
    
    private let rankingUseCase: RankingUseCaseInterface
    private var temporaryRankIndex = 0
    
    init(
        rankingUseCase: RankingUseCaseInterface,
        score: Double
    ) {
        self.rankingUseCase = rankingUseCase
        self.score = score
    }
    
    func onViewAppear() {
        executeSimultaneously()
    }
    
    func rankingRegistered(_ ranking: Ranking) {
        rankingList.insert(ranking, at: temporaryRankIndex)
        outputEvent.send(.scrollCellToCenter(index: temporaryRankIndex))
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
            _ = await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    do {
                        // 0.5秒後に名前登録ダイアログを表示する
                        try await Task.sleep(nanoseconds: 500000000)
                        self.isNameRegisterViewPresented = true
                        
                    } catch {
                        self.error = (error: error, isAlertPresented: true)
                    }
                }
                group.addTask {
                    self.isLoading = true
                    do {
                        self.rankingList = try await self.rankingUseCase.getSortedRanking()
                        self.calculateRankAndNotify()

                    } catch {
                        self.error = (error: error, isAlertPresented: true)
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    // 今回のスコアが既存のランキングの中で何位に入り込むかを算出し、名前登録画面に受け渡しているsubjectに流す
    private func calculateRankAndNotify() {
        temporaryRankIndex = rankingList.firstIndex(where: { $0.score <= score }) ?? 0
        let temporaryRankText = "\(temporaryRankIndex + 1) / \(rankingList.count)"
        temporaryRankTextSubject.send(temporaryRankText)
    }
}
