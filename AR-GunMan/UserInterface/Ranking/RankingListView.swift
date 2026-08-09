//
//  RankingListView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 23/12/24.
//

import SwiftUI
import Domain

struct RankingListView: View {
    let dataList: [RankingListItemData]
    @Binding var isLoading: Bool
    
    var body: some View {
        if isLoading {
            // インジケーター
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.paper)
                .scaleEffect(1.8)
            
        } else {
            // ランキング
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    Spacer()
                        .frame(height: 10)
                    
                    ForEach(dataList) { data in
                        RankingListItem(data: data)
                            .id(data.rank) // 特定セルを画面中央までスクロールさせる制御の為に判別用のidentifierが必要なので設定する
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
            dataList: Array<Int>(1...100).map({
                return .init(rank: String(101 - $0), score: String(101 - $0), userName: "ユーザー\($0)")
            }),
            isLoading: .constant(false)
        )
    }
}
