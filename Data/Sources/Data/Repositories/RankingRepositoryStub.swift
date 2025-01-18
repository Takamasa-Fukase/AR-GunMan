//
//  RankingRepositoryStub.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 10/1/25.
//

import Foundation
import Domain

public final class RankingRepositoryStub: RankingRepositoryInterface {
    public init() {}
    
    public func getRanking() async throws -> [Ranking] {
        print("getRanking")
        try await Task.sleep(nanoseconds: 1500000000)
        print("sleep 終了")
        return Array<Int>(1...100).map({
            return .init(score: Double(101 - $0), userName: "ユーザー\($0)")
        })
    }
    
    public func registerRanking(_ ranking: Ranking) async throws {
        print("registerRanking")
        try await Task.sleep(nanoseconds: 1500000000)
        print("sleep 終了")
    }
}
