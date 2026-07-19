//
//  GameView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import SwiftUI
import Presentation
import Domain

struct GameView<ARView: View>: View {
    let arView: ARView
    @State var viewModel: GameViewModel
    // TODO: リトライ方法の再検討の時に消せるかどうか見直し
    @State var gameViewId = UUID()
    @Environment(\.dismiss) var dismiss
    
    init(
        arView: ARView,
        viewModel: GameViewModel
    ) {
        self.arView = arView
        self.viewModel = viewModel
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack(alignment: .center) {
            // ARコンテンツ部分
            arView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    // タイムカウント
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundStyle(Color.goldLeaf.opacity(0.7))
                        .frame(width: 120, height: 50, alignment: .center)
                        .overlay {
                            Text(viewModel.timeCountText)
                                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 35, weight: .regular)))
                                .foregroundStyle(Color.paper)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.customDarkBrown.opacity(0.7), lineWidth: 3)
                        }
                    
                    Spacer()
                    
                    // 武器変更ボタン
                    Button {
                        // 武器選択画面を表示
                        viewModel.weaponChangeButtonTapped()
                        
                    } label: {
                        Image("weapon_change")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                    }
                    .disabled(!viewModel.isWeaponChangeButtonEnabled)
                }
                .padding(EdgeInsets(top: 30, leading: 20, bottom: 0, trailing: 12))
                
                Spacer()
                
                // 武器変更画面の表示中は邪魔になって見ずらいので隠す
                if !viewModel.isWeaponSelectViewPresented {
                    // 弾数画像
                    HStack(spacing: 0) {
                        Image(viewModel.bulletsCountImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 210, height: 70, alignment: .bottom)
                        
                        Spacer()
                    }
                }
            }
            
            // 武器変更画面の表示中は邪魔になって見ずらいので隠す
            if !viewModel.isWeaponSelectViewPresented {
                // 照準画像
                Image(viewModel.currentWeaponType.resources.sightImageName)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                // TODO: 普通に最初からColorをresourcesに持たせるようにする & 不要になったConverterを消す
                    .foregroundStyle(ColorTypeConverter.fromColorType(viewModel.currentWeaponType.resources.sightImageColorType))
            }
        }
        .background(Color.black)
        .onAppear {
            viewModel.onViewAppear()
        }
        .onDisappear {
            viewModel.onViewDisappear()
        }
        // チュートリアル画面への遷移
        .fullScreenCover(
            isPresented: $viewModel.isTutorialViewPresented,
            onDismiss: {
                // チュートリアルの完了を通知
                viewModel.tutorialEnded()
            }
        ) {
            ZStack(alignment: .center) {
                Color.black.opacity(0.7)
                UIBlurEffectViewRepresentable()
                TutorialViewBuilder.build()
            }
            .ignoresSafeArea()
            // sheetの背景を透過
            .presentationBackground(.clear)
        }
        // 武器選択画面に遷移
        .fullScreenCover(isPresented: $viewModel.isWeaponSelectViewPresented) {
            WeaponSelectViewBuilder.build(
                initialDisplayWeaponType: viewModel.currentWeaponType,
                weaponSelected: { weaponType in
                    viewModel.weaponSelected(weaponType: weaponType)
                }
            )
            // sheetの背景を透過
            .presentationBackground(.clear)
            .ignoresSafeArea()
        }
        // 結果画面に遷移
        .fullScreenCover(isPresented: $viewModel.isResultViewPresented.isPresented) {
            ResultViewBuilder.build(
                score: viewModel.isResultViewPresented.score,
                replayButtonTapped: {
                    resetAllAndRestartGame()
                },
                toHomeButtonTapped: {
                    dismiss()
                }
            )
        }
        .id(gameViewId)
    }
    
    // TODO: リトライ時には画面自体を外側から丸ごと初期化し直させるようにしたい
    private func resetAllAndRestartGame() {
        // 依存を初期化し直してリセット
//        let (arShootingLibHandler, arView) = Factory.create(
//            frame: .zero,
//            // TODO: targetCountはConstにしたい
//            targetCount: 50
//        )
//        self.arView = arView as! ARView
//        let viewModel = GameViewModel(
//            arShootingLibHandler: arShootingLibHandler,
//            tutorialRepository: Factory.create(),
//            gameTimerCreateUseCase: Factory.create(),
//            weaponResourceGetUseCase: Factory.create(),
//            weaponActionExecuteUseCase: Factory.create()
//        )
//        let motionDetector = WeaponControlMotionDetector()
//        self.motionDetector = motionDetector
//        self.viewModel = viewModel
//        // 依存先からのコールバックをVMに接続しなおし
//        connectDependencyCallbacksToViewModel()
//        // ルート階層のidを更新してビューを丸ごと再描画し、onAppearを呼ばせることでゲームをリスタートさせる
//        gameViewId = UUID()
    }
}

#Preview {
    GameViewBuilder.build(frame: .zero)
}
