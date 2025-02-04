//
//  Ranking.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2022/01/31.
//

import Foundation

public struct Ranking: Codable, Identifiable, Equatable {
    public let id: UUID
    public let score: Double
    public let userName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case score
        case userName = "user_name"
    }
    
    public init(
        score: Double,
        userName: String
    ) {
        self.id = UUID()
        self.score = score
        self.userName = userName
    }
    
    // MARK: ユニットテスト時のみアクセスする
    #if DEBUG
    init(
        id: UUID,
        score: Double,
        userName: String
    ) {
        self.id = id
        self.score = score
        self.userName = userName
    }
    #endif
}
