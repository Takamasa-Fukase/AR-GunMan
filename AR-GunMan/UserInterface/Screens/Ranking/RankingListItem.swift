//
//  RankingListItem.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 23/12/24.
//

import SwiftUI

struct RankingListItem: View {
    let rank: Int
    let score: Double
    let userName: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 背景1
            Color.customDarkBrown
                .frame(maxWidth: .infinity)
                .border(Color.goldLeaf, width: 4)
            
            // 四隅の白い点
            whiteCornerSquares
                .padding(EdgeInsets(top: 8, leading: 2, bottom: 8, trailing: 2))
            
            // 背景2
            Color.customLightBrown
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
            
            HStack(alignment: .bottom, spacing: 0) {
                // 順位
                Text(String(rank))
                    .font(.custom("Copperplate Bold", size: 22))
                    .minimumScaleFactor(0.5) // 文字数が多い場合は50%まで縮小
                    .frame(width: 32, height: 22)
                    .background(Color.goldLeaf)
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 4, trailing: 0))
                
                // スコア
                Text(score.scoreText)
                    .font(.custom("Copperplate", size: 22))
                    .frame(alignment: .centerLastTextBaseline)
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 13, trailing: 10))
                
                // ユーザー名
                Text(userName)
                    .font(.custom("Copperplate Bold", size: 38))
                    .minimumScaleFactor(0.5) // 文字数が多い場合は50%まで縮小
                    .frame(height: 38)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 14))
            }
        }
        .foregroundStyle(.white)
        .padding(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
        .frame(height: 48)
    }
    
    private var whiteCornerSquares: some View {
        VStack {
            HStack {
                Color.paper
                    .frame(width: 4, height: 2)
                
                Spacer()
                
                Color.paper
                    .frame(width: 4, height: 2)
            }
            
            Spacer()
            
            HStack {
                Color.paper
                    .frame(width: 4, height: 2)
                
                Spacer()
                
                Color.paper
                    .frame(width: 4, height: 2)
            }
        }
    }
}

#Preview {
    CenterPreviewView(backgroundColor: .black) {
        VStack(alignment: .center, spacing: 0) {
            RankingListItem(rank: 1, score: 100.00, userName: "マイケル")
            RankingListItem(rank: 2, score: 99.000, userName: "Adam")
            RankingListItem(rank: 3, score: 98.000, userName: "Jof")
            RankingListItem(rank: 4, score: 97.000, userName: "次郎")
            RankingListItem(rank: 5, score: 96.000, userName: "ジェシー")
            RankingListItem(rank: 6, score: 95.000, userName: "田中太郎")
        }
        .frame(width: 341.33, height: 319)
    }
}
