//
//  Ranking.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/31.
//

import Foundation

public struct Ranking: Codable, Identifiable {
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
