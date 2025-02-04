//
//  RankingUseCaseTests.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 4/2/25.
//

import XCTest
@testable import Domain

final class RankingUseCaseTests: XCTestCase {
    private var rankingRepositorySpyStub: RankingRepositorySpyStub!
    private var rankingUseCase: RankingUseCase!
    
    override func setUp() {
        rankingRepositorySpyStub = .init()
        rankingUseCase = .init(rankingRepository: rankingRepositorySpyStub)
    }
    
    override func tearDown() {
        rankingRepositorySpyStub = nil
        rankingUseCase = nil
    }
    
    func test_hoge() {
        
    }
}
