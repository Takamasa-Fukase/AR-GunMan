//
//  Ranking.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2022/01/31.
//

import Foundation

public struct RankingItem: Codable, Identifiable, Equatable {
    public let id = UUID()
    public let score: Double
    public let userName: String
    
    enum CodingKeys: String, CodingKey {
        case score
        case userName = "user_name"
    }
    
    public init(
        score: Double,
        userName: String
    ) {
        self.score = score
        self.userName = userName
    }
}

public struct Ranking {
    public private(set) var items: [RankingItem]
    
    public init(items: [RankingItem]) {
        // スコアの高い順にソート
        let sortedItems = items.sorted { $0.score > $1.score }
        self.items = sortedItems
    }
    
    public func getTentativeRankIndex(for score: Double) -> Int {
        return items.firstIndex(where: { $0.score <= score }) ?? 0
    }
    
    mutating func insertRegisteredRanking(item: RankingItem) {
        let tentativeRankIndex = getTentativeRankIndex(for: item.score)
        items.insert(item, at: tentativeRankIndex)
    }
}
