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
        temporaryRankIndex: Int,
        rankingListCount: Int
    ) -> String {
        // スコア表示は1から始まるので＋1する
        let temporaryRankNumber = temporaryRankIndex + 1
        return "\(temporaryRankNumber) / \(rankingListCount)"
    }
    
    // 取得したランキング順位の中から今回のスコア（まだ未登録）を差し込むと暫定何位になるかを計算して返却
    static func getTemporaryRankIndex(
        rankingList: [RankingListItemModel],
        score: Double
    ) -> Int {
        // スコアの高い順になっているリストの中から最初に引数のscore以下のランクのindex番号を取得
        return rankingList.firstIndex(where: { $0.score <= score }) ?? 0
    }
}
