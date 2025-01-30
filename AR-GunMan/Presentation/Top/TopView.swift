//
//  TopView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import SwiftUI

struct TopView: View {
    @State var viewModel: TopViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        GeometryReader { geometry in
            VStack(alignment: .trailing, spacing: 0) {
                Spacer()
                    .frame(height: geometry.size.height * 0.1)
                    .frame(maxWidth: .infinity)
                
                Image("ar_gunman_title_image", bundle: .main)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 510, height: 70)
                    .padding(.trailing, 40)
                    .padding(.bottom, 12)
                
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 40)
                        .frame(maxHeight: .infinity)
                    
                    VStack(spacing: 0) {
                        targetIconButton(title: "Start", isIconSwitched: viewModel.isStartButtonIconSwitched) {
                            viewModel.startButtonTapped()
                        }
                                                
                        targetIconButton(title: "Settings", isIconSwitched: viewModel.isSettingsButtonIconSwitched) {
                            viewModel.settingsButtonTapped()
                        }
                        
                        targetIconButton(title: "HowToPlay", isIconSwitched: viewModel.isHowToPlayButtonIconSwitched) {
                            viewModel.howToPlayButtonTapped()
                        }
                    }
                    .frame(width: (geometry.size.width) * 0.54)
                    .frame(maxHeight: .infinity)
                    
                    Image("top_page_pistol_icon", bundle: .main)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.bottom, 16)
                .padding(.trailing, 14)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // ゲーム画面への遷移
            .fullScreenCover(isPresented: $viewModel.isGameViewPresented) {
                GameViewFactory.create(frame: geometry.frame(in: .global))
            }
        }
        .background(Color.goldLeaf)
        .onAppear {
            viewModel.onViewAppear()
        }
        .onReceive(viewModel.playSound) { soundType in
            SoundPlayer.shared.play(soundType)
        }
        .alert(
            "Camera Permission Required",
            isPresented: $viewModel.isPermissionRequiredAlertPresented,
            actions: {
                Button("Yes") {
                    openDeviceSettings()
                }
                Button("Not now", role: .cancel) {}
            },
            message: {
                Text("Camera Permission is required to play this game.\nDo you want to change your settings?")
            }
        )
        // 設定画面への遷移
        .fullScreenCover(isPresented: $viewModel.isSettingsViewPresented) {
            SettingsViewFactory.create()
        }
        // チュートリアル画面への遷移
        .showCustomModal(
            isPresented: $viewModel.isTutorialViewPresented
        ) { dismissRequestReceiver in
            TutorialViewFactory.create(
                // 内部からのdismissリクエストをレシーバーに送信できる様に受け渡し
                dismissRequestReceiver: dismissRequestReceiver
            )
            // sheetの背景を透過
            .presentationBackground(.clear)
        }
    }
    
    private func targetIconButton(
        title: String,
        isIconSwitched: Bool,
        onTap: @escaping (() -> Void)
    ) -> some View {
        HStack(alignment: .center, spacing: 8) {
            GeometryReader { geometry in
                buttonImage(isIconSwitched: isIconSwitched)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.height)
                    .foregroundStyle(Color.blackSteel)
            }
            .frame(width: 40, height: 40)
            
            Button {
                onTap()
            } label: {
                Text(title)
                    .foregroundStyle(Color.blackSteel)
                    .font(.custom("Copperplate Bold", size: 50))
                    .underline()
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func buttonImage(isIconSwitched: Bool) -> some View {
        if isIconSwitched {
            Image("bullets_hole", bundle: .main)
                .resizable()
        }else {
            Image(systemName: "target")
                .resizable()
        }
    }
    
    private func openDeviceSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        // 設定アプリを開く
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
}

#Preview {
    TopViewFactory.create()
}
