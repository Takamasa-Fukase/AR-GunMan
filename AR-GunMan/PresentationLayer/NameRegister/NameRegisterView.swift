//
//  NameRegisterView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/1/25.
//

import SwiftUI
import Combine
import DataLayer
import DomainLayer

struct NameRegisterView: View {
    @State var viewModel: NameRegisterViewModel
    var dismissRequestReceiver: DismissRequestReceiver
    var onRegistered: (Ranking) -> Void
        
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            Group {
                Spacer()
                    .frame(height: 14)
                
                Text("Congratulations!")
                    .font(.custom("Copperplate Bold", size: 25))
                    .foregroundStyle(Color.paper)
                    .frame(height: 25)
                
                HStack(spacing: 0) {
                    Text("You're ranked at ")
                        .font(.custom("Copperplate", size: 21))
                        .foregroundStyle(Color.paper)
                    
                    Group {
                        if viewModel.temporaryRankText.isEmpty {
                            // インジケーター
                            progressView
                            
                        } else {
                            // ランク表示
                            Text(viewModel.temporaryRankText)
                                .font(.custom("Copperplate", size: 25))
                                .foregroundStyle(Color.customDarkBrown)
                        }
                    }
                    .frame(minWidth: 58)
                    
                    Text(" in")
                        .font(.custom("Copperplate", size: 21))
                        .foregroundStyle(Color.paper)
                }
                .frame(height: 25.5)
                
                Text("the world!")
                    .font(.custom("Copperplate", size: 21))
                    .foregroundStyle(Color.paper)
                    .frame(height: 21.5)
                
                // スコア表示
                Text("Score: \(viewModel.score.scoreText)")
                    .font(.custom("Copperplate Bold", size: 38))
                    .foregroundStyle(Color.paper)
                    .frame(height: 36)

                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 24)
                    
                    Text("Name:")
                        .font(.custom("Copperplate", size: 20))
                        .foregroundStyle(Color.paper)
                    
                    Spacer()
                        .frame(width: 4)
                    
                    // 名前入力フォーム
                    TextField("", text: $viewModel.nameText)
                        .font(.custom("Copperplate", size: 30))
                        .foregroundStyle(Color.goldLeaf)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.customDarkBrown)
                                .frame(height: 40)
                        )
                        .frame(height: 40)
                    
                    Spacer()
                        .frame(width: 24)
                }
                
                Spacer()
                    .frame(height: 16)
            }
            .foregroundStyle(Color.paper)
            
            Color.black
                .frame(height: 1)
            
            HStack(spacing: 0) {
                // キャンセルボタン
                Button {
                    viewModel.noButtonTapped()
                } label: {
                    Text("No, thanks")
                        .font(.custom("Copperplate Bold", size: 22))
                        .foregroundStyle(Color(.darkGray))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Color.black
                    .frame(width: 1)
                
                // 登録ボタン
                Button {
                    viewModel.registerButtonTapped()
                } label: {
                    if viewModel.isRegistering {
                        // インジケーター
                        progressView
                        
                    } else {
                        Text("Register!")
                            .font(.custom("Copperplate Bold", size: 28))
                            .foregroundStyle(.black)
                            .opacity(viewModel.isRegisterButtonEnabled ? 1 : 0.1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .disabled(!viewModel.isRegisterButtonEnabled)
            }
            .frame(height: 46)
        }
        .frame(width: 412)
        .background(Color.goldLeaf)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        // 枠線を重ねる
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.paper, lineWidth: 1)
                .padding(0.5)
        }
        .padding(.all, 3.8)
        // 外側の枠線を重ねる
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.paper, lineWidth: 2)
        }
        .onReceive(viewModel.notifyRegistrationCompletion) { ranking in
            onRegistered(ranking)
        }
        .onReceive(viewModel.dismiss) {
            dismissRequestReceiver.subject.send(())
        }
    }
    
    var progressView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(Color.paper)
    }
}

#Preview {
    CenterPreviewView(backgroundColor: .black) {
        NameRegisterViewFactory.create(
            score: 0.0,
            temporaryRankTextSubject: CurrentValueSubject<String, Never>(""),
            dismissRequestReceiver: DismissRequestReceiver(),
            onRegistered: { _ in }
        )
    }
}
