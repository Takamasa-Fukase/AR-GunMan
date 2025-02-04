//
//  RankingUseCaseTests.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 4/2/25.
//

import XCTest
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
    
    func test_getSortedRanking_() {
        
    }
}
