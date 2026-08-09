//
//  RankingRepositoryInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 10/1/25.
//

import Foundation

public protocol RankingRepositoryInterface: AnyObject {
    func getItems() async throws -> [RankingItem]
    func registerItem(_ item: RankingItem) async throws
}
