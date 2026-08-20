//
//  RankingStore.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/07/10.
//

import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class RankingStore: RankingStoreInterface {
    public static let shared = RankingStore()
    
    public var ranking: Ranking?
    
    private init() {}
    
    public func reset() {
        ranking = nil
    }
}
