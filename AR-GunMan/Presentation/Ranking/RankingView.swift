//
//  RankingView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 23/12/24.
//

import SwiftUI

struct RankingView: View {
    let viewModel: RankingViewModel
    let dismissRequestReceiver: DismissRequestReceiver
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    // 外側のダークブラウン色の枠線
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.customDarkBrown, lineWidth: 5)
                        .padding(.top, 15)
                        .padding(.all, 2.4)

                    VStack(spacing: 0) {
                        // タイトル部分と閉じるボタン
                        titleView
                            .padding(.bottom, 8)

                        ZStack {
                            // ランキング
                            RankingListView(rankingList: viewModel.rankingList)

                            // 内側の枠線
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.goldLeaf, lineWidth: 7)
                                .padding(.all, 3.4)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                }
                .frame(width: (geometry.size.width * 0.5) + 20)
                .padding(EdgeInsets(top: 24, leading: 0, bottom: 30, trailing: 0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .task {
            await viewModel.getRanking()
        }
        .onReceive(viewModel.dismiss) {
            dismissRequestReceiver.subject.send(())
        }
    }
    
    private var titleView: some View {
        ZStack {
            Color.goldLeaf
                .frame(height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: 60)
                
                Text("WORLD RANKING")
                    .font(.custom("Copperplate Bold", size: 30))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5) // 最大50%までは縮小を許可する
                
                Button {
                    viewModel.closeButtonTapped()
                } label: {
                    Image(systemName: "xmark")
                        .tint(.blackSteel)
                        .font(.system(size: 17, weight: .bold))
                        .frame(width: 60)
                }
            }
        }
    }
}

#Preview {
    RankingViewFactory.create(
        dismissRequestReceiver: DismissRequestReceiver()
    )
    .background(.black)
}
