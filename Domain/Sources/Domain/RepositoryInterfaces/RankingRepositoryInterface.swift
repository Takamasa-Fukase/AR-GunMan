//
//  RankingRepositoryInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 10/1/25.
//

import Foundation

@MainActor
public protocol RankingRepositoryInterface: AnyObject {
    var items: [RankingItem]? { get }
    func getRankingItems() async throws
    func getTentativeRankIndex(for score: Double) -> Int
    func registerRankingItem(_ item: RankingItem) async throws
    func insertRegisteredRanking(at index: Int, item: RankingItem)
}
