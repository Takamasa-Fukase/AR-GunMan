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
    let score: Double
    private(set) var rankingList: [Ranking] = []
    var isNameRegisterViewPresented = false
    var isLoading = false
    var error: (error: Error?, isAlertPresented: Bool) = (nil, false)
    
    let showButtons = PassthroughSubject<Void, Never>()
    let dismissAndNotifyReplayButtonTap = PassthroughSubject<Void, Never>()
    let notifyHomeButtonTap = PassthroughSubject<Void, Never>()
    let scrollCellToCenter = PassthroughSubject<Int, Never>()
    let temporaryRankTextSubject = CurrentValueSubject<String, Never>("")
    
    private let rankingRepository: RankingRepositoryInterface
    private var temporaryRankIndex = 0
    
    init(
        rankingRepository: RankingRepositoryInterface,
        score: Double
    ) {
        self.rankingRepository = rankingRepository
        self.score = score
    }
    
    func onViewAppear() {
        executeSimultaneously()
    }
    
    func rankingRegistered(_ ranking: Ranking) {
        rankingList.insert(ranking, at: temporaryRankIndex)
        scrollCellToCenter.send(temporaryRankIndex)
    }
    
    func nameRegisterViewClosed() {
        showButtons.send(())
    }
    
    func replayButtonTapped() {
        dismissAndNotifyReplayButtonTap.send(())
    }
    
    func toHomeButtonTapped() {
        notifyHomeButtonTap.send(())
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
                        print("showNameRegisterView error: \(error)")
                    }
                }
                group.addTask {
                    self.isLoading = true
                    do {
                        // ランキングの一覧を取得
                        let rankingList = try await self.rankingRepository.getRanking()
                        // スコアの高い順にソートして代入
                        self.rankingList = rankingList.sorted(by: { $0.score > $1.score })
                        
                        // 今回のスコアが既存のランキングの中で何位に入り込むかを算出し、
                        // 名前登録画面に受け渡しているsubjectに流す
                        self.temporaryRankIndex = self.rankingList.firstIndex(where: { $0.score <= self.score }) ?? 0
                        let temporaryRankText = "\(self.temporaryRankIndex + 1) / \(self.rankingList.count)"
                        self.temporaryRankTextSubject.send(temporaryRankText)

                    } catch {
                        self.error = (error: error, isAlertPresented: true)
                    }
                    self.isLoading = false
                }
            }
        }
    }
}
