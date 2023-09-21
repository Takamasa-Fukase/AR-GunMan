//
//  Ranking.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/31.
//

import Foundation

struct Ranking: Codable {
    let score: Double
    let userName: String
    
    enum CodingKeys: String, CodingKey {
        case score
        case userName = "user_name"
    }
}
