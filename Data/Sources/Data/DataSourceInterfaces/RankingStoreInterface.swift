//
//  RankingStoreInterface.swift
//  Data
//
//  Created by ウルトラ深瀬 on 2026/07/10.
//

import Foundation
import Domain

@MainActor
public protocol RankingStoreInterface: AnyObject {
    var ranking: Ranking? { get set }
}
