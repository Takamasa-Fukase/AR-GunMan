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
        // MARK: 正常系のテスト
        /*
         テストしたいこと
         スコア順バラバラなリストをセットして、それがスコアの高い順にソートされて取得されること
         */
        
        // テストで比較可能にする為に、固定のidを使う
        let id = UUID()
        rankingRepositoryMock.rankingList = [
            .init(id: id, score: 9.000, userName: ""),
            .init(id: id, score: 100.00, userName: ""),
            .init(id: id, score: 0.000, userName: ""),
            .init(id: id, score: 50.000, userName: "")
        ]
        let expectedRankingList: [Ranking] = [
            .init(id: id, score: 100.00, userName: ""),
            .init(id: id, score: 50.000, userName: ""),
            .init(id: id, score: 9.000, userName: ""),
            .init(id: id, score: 0.000, userName: "")
        ]
        
        let rankingList = try await rankingUseCase.getSortedRanking()
        
        XCTAssertEqual(rankingList, expectedRankingList)
        
        
        // MARK: 異常系のテスト
        /*
         テストしたいこと
         apiClientErrorエラーをセットしてから取得しようとしたら、
         - エラーをキャッチして、エラーのcaseが.apiClientErrorであること（他のcaseだとNG）
         - 取得メソッドの次の行に進まないこと
         */
        
        rankingRepositoryMock.error = CustomError.apiClientError(CustomError.other(message: ""))
        
        do {
            _ = try await rankingUseCase.getSortedRanking()
            XCTFail("エラーの発生を期待していたが発生せずに成功したため、テストを失敗させました。")
            
        } catch {
            guard let customError = error as? CustomError,
                  case .apiClientError(_) = customError else {
                XCTFail("エラーの種別が期待していたCustomErrorではないため、テストを失敗させました。")
                return
            }
        }
    }
}
