//
//  RankingListView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 23/12/24.
//

import SwiftUI
import Domain

struct RankingListView: View {
    let rankingList: [Ranking]
    @Binding var isLoading: Bool
    
    var body: some View {
        if isLoading {
            // インジケーター
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.paper)
                .scaleEffect(1.8)
            
        }else {
            // ランキング
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    Spacer()
                        .frame(height: 10)
                    
                    ForEach(Array(rankingList.enumerated()), id: \.offset) { (index, ranking) in
                        RankingListItem(rank: index + 1, score: ranking.score, userName: ranking.userName)
                            .id(index) // 特定セルを画面中央までスクロールさせる制御の為にidが必要なので設定する
                    }
                    
                    Spacer()
                        .frame(height: 10)
                }
            }
        }
    }
}

#Preview {
    CenterPreviewView(backgroundColor: .black) {
        RankingListView(
            rankingList: Array<Int>(1...100).map({
                return .init(score: Double(101 - $0), userName: "ユーザー\($0)")
            }),
            isLoading: .constant(false)
        )
    }
}
