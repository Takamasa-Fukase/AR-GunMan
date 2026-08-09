//
//  RankingRepositoryStub.swift
//  Data
//
//  Created by ウルトラ深瀬 on 10/1/25.
//

import Foundation
//import Core
import Domain

public final class RankingRepositoryStub: RankingRepositoryInterface {
    public init() {}
    
    public func getItems() async throws -> [RankingItem] {
        try await Task.sleep(for: .milliseconds(1500))
        let count = 100
        return Array<Int>(1...count).map({
            return .init(score: Double((count + 1) - $0), userName: "ユーザー\($0)")
        })
//        throw CustomError.other(message: "getRanking error")
    }
    
    public func registerItem(_ item: RankingItem) async throws {
        try await Task.sleep(for: .milliseconds(1500))
//        throw CustomError.other(message: "registerRanking error")
    }
}
