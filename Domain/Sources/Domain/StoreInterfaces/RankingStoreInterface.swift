//
//  RankingStoreInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/10.
//

import Foundation

@MainActor
public protocol RankingStoreInterface: AnyObject {
    var ranking: Ranking? { get set }
}
