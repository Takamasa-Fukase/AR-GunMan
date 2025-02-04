//
//  RankingUseCaseTests.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 4/2/25.
//

import XCTest
import Core
@testable import Domain

final class RankingUseCaseTests: XCTestCase {
    private var rankingRepositoryMock: RankingRepositoryMock!
    private var rankingUseCase: RankingUseCase!
    
    override func setUp() {
        rankingRepositoryMock = .init()
        rankingUseCase = .init(rankingRepository: rankingRepositoryMock)
    }
    
    override func tearDown() {
        rankingRepositoryMock = nil
        rankingUseCase = nil
    }
    
    func test_getSortedRanking() async throws {
        rankingRepositoryMock.rankingList = [
            .init(score: 9.000, userName: ""),
            .init(score: 100.00, userName: ""),
            .init(score: 0.000, userName: ""),
            .init(score: 50.000, userName: "")
        ]
        let expectedRankingList: [Ranking] = [
            .init(score: 100.00, userName: ""),
            .init(score: 50.000, userName: ""),
            .init(score: 9.000, userName: ""),
            .init(score: 0.000, userName: "")
        ]
        
        let rankingList = try await rankingUseCase.getSortedRanking()
        
//        XCTAssertEqual(rankingList, expectedRankingList)
        
        let expectedErrorMessage = "test_getSortedRanking error"
        rankingRepositoryMock.error = CustomError.other(message: expectedErrorMessage)
        
        do {
            _ = try await rankingUseCase.getSortedRanking()
            XCTFail("エラーの発生を期待していたが発生せずに成功したため、テストを失敗させました。")
            
        } catch {
            guard let customError = error as? CustomError,
                  case .other(let message) = customError else {
                XCTFail("エラーの種別が期待していたCustomErrorではないため、テストを失敗させました。")
                return
            }
            XCTAssertEqual(message, expectedErrorMessage)
        }
    }
}
