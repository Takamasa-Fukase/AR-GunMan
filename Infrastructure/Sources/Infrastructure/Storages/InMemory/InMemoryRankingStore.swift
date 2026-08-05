//
//  InMemoryRankingStore.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/07/10.
//

import Foundation
import Observation
import Data
import Domain

@Observable
@MainActor
public final class InMemoryRankingStore: RankingStoreInterface {
    public init() {}
    
    public var ranking: Ranking?
}
