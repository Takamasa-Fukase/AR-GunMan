//
//  SettingsView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 17/12/24.
//

import SwiftUI
import Presentation

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: SettingsViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(alignment: .leading, spacing: 0) {
            Text("Settings")
                .foregroundStyle(Color.blackSteel)
                .font(.custom("Copperplate Bold", size: 42))
            
            VStack(alignment: .center, spacing: 0) {
                underlineButton(title: "World Ranking", fontSize: 40) {
                    viewModel.worldRankingButtonTapped()
                }
                underlineButton(title: "Privacy Policy", fontSize: 40) {
                    viewModel.privacyPolicyButtonTapped()
                }
                underlineButton(title: "Contact Developer", fontSize: 40) {
                    viewModel.contactDeveloperButtonTapped()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            underlineButton(title: "Back", fontSize: 36) {
                viewModel.backButtonTapped()
            }
            .frame(height: 50)
        }
        .padding(EdgeInsets(top: 50, leading: 30, bottom: 40, trailing: 30))
        .background(Color.goldLeaf)
        // ランキング画面へ遷移
        .showCustomModal(isPresented: $viewModel.isRankingViewPresented) { dismissRequestReceiver in
            RankingViewBuilder.build(dismissRequestReceiver: dismissRequestReceiver)
        }
        // プライバシーポリシーをWebView表示
        .fullScreenCover(isPresented: $viewModel.isPrivacyPolicyViewPresented) {
            SafariViewControllerRepresentable(
                url: URL(string: URLConst.PRIVACY_POLICY)!
            )
            .ignoresSafeArea()
        }
        // 開発者への問い合わせ画面をWebView表示
        .fullScreenCover(isPresented: $viewModel.isDeveloperContactViewPresented) {
            SafariViewControllerRepresentable(
                url: URL(string: URLConst.DEVELOPER_CONTACT)!
            )
            .ignoresSafeArea()
        }
        .task {
            for await event in viewModel.outputEvent {
                switch event {
                case .dismiss:
                    dismiss()
                }
            }
        }
    }
    
    private func underlineButton(
        title: String,
        fontSize: CGFloat,
        onTap: @escaping (() -> Void)
    ) -> some View {
        Button {
            onTap()
        } label: {
            Text(title)
                .foregroundStyle(Color.blackSteel)
                .font(.custom("Copperplate Bold", size: fontSize))
                .underline()
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
