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
    
    // TODO: 後でRankingPresenterを作ったらインターナル呼び出しのみになるのでDomain側のIFからは削除する
    func reset()
}
