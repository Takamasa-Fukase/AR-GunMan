//
//  ResultView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 22/12/24.
//

import SwiftUI

struct ResultView: View {
    @State var viewModel: ResultViewModel
    @State var isButtonsBaseViewVisible = false
    @State var buttonsOpacity = 0.0
    @Environment(\.dismiss) var dismiss
    let replayButtonTapped: (() -> Void)
    let toHomeButtonTapped: (() -> Void)
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        GeometryReader { safeAreaGeometry in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 10)
                
                // 上部のタイトル部分
                titleView
                
                Spacer()
                    .frame(height: 8)
                
                // ランキングとスコア表示、ボタン表示の領域
                GeometryReader { rankingAndScoreAreaGeometry in
                    HStack(spacing: 0) {
                        
                        ZStack {
                            ScrollViewReader { scrollProxy in
                                // ランキング
                                RankingListView(rankingList: viewModel.rankingList)
                                // MEMO: scrollProxyを使用する為この位置で.onReceiveしている
                                    .onReceive(viewModel.scrollCellToCenter) { index in
                                        withAnimation {
                                            scrollProxy.scrollTo(index, anchor: .center)
                                        }
                                    }
                            }
                            
                            RoundedRectangle(cornerRadius: 1)
                                .stroke(lineWidth: 7)
                                .padding(.all, 3.5)
                                .foregroundStyle(Color.goldLeaf)
                        }
                        .frame(width: safeAreaGeometry.size.width * 0.465)
                        .clipped()
                        
                        Spacer()
                        
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(lineWidth: 7)
                                    .padding(.all, 3.5)
                                    .foregroundStyle(Color.goldLeaf)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("SCORE")
                                        .font(.custom("Copperplate", size: 22))
                                        .frame(width: 75, height: 23)
                                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 0))
                                        .minimumScaleFactor(0.5) // 最大50%までは縮小を許可する
                                    
                                    Text("\(viewModel.score.scoreText)")
                                        .font(.custom("Copperplate Bold", size: 80))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .minimumScaleFactor(0.5) // 最大50%までは縮小を許可する
                                        .padding(.bottom, 5)
                                }
                            }
                            .frame(height: (rankingAndScoreAreaGeometry.size.height - 20) * 0.33125)
                            
                            Spacer()
                                .frame(height: 6)
                            
                            ZStack(alignment: .center) {
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(lineWidth: 7)
                                    .padding(.all, 3.5)
                                    .foregroundStyle(Color.goldLeaf)
                                
                                GeometryReader { actionButtonsAreaGeometry in
                                    ZStack {
                                        HStack(spacing: 0) {
                                            if isButtonsBaseViewVisible {
                                                Spacer()
                                                    .frame(width: actionButtonsAreaGeometry.size.width * 0.62)
                                            }
                                            
                                            VStack(spacing: 0) {
                                                Button {
                                                    viewModel.replayButtonTapped()
                                                } label: {
                                                    Text("REPLAY")
                                                        .font(.custom("Copperplate Bold", size: 25))
                                                        .frame(maxHeight: .infinity)
                                                        .opacity(buttonsOpacity)
                                                }
                                                
                                                Button {
                                                    viewModel.toHomeButtonTapped()
                                                } label: {
                                                    Text("HOME")
                                                        .font(.custom("Copperplate Bold", size: 25))
                                                        .frame(maxHeight: .infinity)
                                                        .opacity(buttonsOpacity)
                                                }
                                            }
                                        }
                                        
                                        HStack(spacing: 0) {
                                            Image("pistol")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: actionButtonsAreaGeometry.size.width * 0.62)
                                            
                                            if isButtonsBaseViewVisible {
                                                Spacer()
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.all, 20)
                            }
                        }
                        .frame(width: safeAreaGeometry.size.width * 0.465)
                    }
                    .padding(.all, 10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(lineWidth: 5)
                            .padding(.all, 2.5)
                            .foregroundStyle(Color.customDarkBrown)
                    }
                }
                .foregroundStyle(Color.paper)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(.black)
        .onAppear {
            viewModel.onViewAppear()
        }
        .onReceive(viewModel.showButtons) { _ in
            withAnimation(.linear(duration: 0.6)) {
                isButtonsBaseViewVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                withAnimation(.linear(duration: 0.25)) {
                    buttonsOpacity = 1
                }
            })
        }
        .onReceive(viewModel.dismissAndNotifyReplayButtonTap) { _ in
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                dismiss()
            }
            replayButtonTapped()
        }
        .onReceive(viewModel.notifyHomeButtonTap) { _ in
            toHomeButtonTapped()
        }
        // 名前登録画面へ遷移
        .showCustomModal(
            isPresented: $viewModel.isNameRegisterViewPresented,
            onDismiss: {
                viewModel.nameRegisterViewClosed()
            }
        ) { dismissRequestReceiver in
            NameRegisterViewFactory.create(
                score: viewModel.score,
                temporaryRankTextSubject: viewModel.temporaryRankTextSubject,
                dismissRequestReceiver: dismissRequestReceiver,
                onRegistered: { ranking in
                    viewModel.rankingRegistered(ranking)
                }
            )
        }
    }
    
    private var titleView: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 3)
                .frame(height: 20)
                .foregroundStyle(Color.customDarkBrown)
                .overlay {
                    RoundedRectangle(cornerRadius: 1.5)
                        .stroke(lineWidth: 3)
                        .padding(.all, 1.5)
                        .foregroundStyle(Color.goldLeaf)
                }
            
            Text("WORLD RANKING")
                .font(.custom("Copperplate Bold", size: 30))
                .padding(.horizontal, 30)
                .background(
                    Color.goldLeaf
                        .frame(height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                )
                .padding(.top, 6)
        }
    }
}

#Preview {
    CenterPreviewView(backgroundColor: .black) {
        ResultViewFactory.create(
            score: 98.765,
            replayButtonTapped: {},
            toHomeButtonTapped: {}
        )
    }
}
