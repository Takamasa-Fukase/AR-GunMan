//
//  RankingUtil.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/02/15.
//

import Foundation

final class RankingUtil {
    // 何位中/何位の表示テキストを作成
    static func createTemporaryRankText(
        rankingList: [Ranking],
        score: Double
    ) -> String? {
        guard !rankingList.isEmpty else { return nil }
        // スコア表示は1から始まるので＋1する
        let temporaryRankNumber = getTemporaryRankIndex(rankingList: rankingList, score: score)
        return "\(temporaryRankNumber) / \(rankingList.count)"
    }
    
    // 取得したランキング順位の中から今回のスコア（まだ未登録）を差し込むと暫定何位になるかを計算して返却
    static func getTemporaryRankIndex(
        rankingList: [Ranking],
        score: Double
    ) -> Int {
        // スコアの高い順になっているリストの中から最初にtotalScore以下のランクのindex番号を取得
        return rankingList.firstIndex(where: { $0.score <= score }) ?? 0
    }
}
