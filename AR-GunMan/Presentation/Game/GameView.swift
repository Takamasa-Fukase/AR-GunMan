//
//  GameView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import SwiftUI
import ARShooting
import WeaponControlMotion

struct GameView: View {
    @State var arController: ARShootingController
    @State var motionDetector: WeaponControlMotionDetector
    @State var viewModel: GameViewModel
    @State var gameViewId = UUID()
    @Environment(\.dismiss) var dismiss
    
    init(
        arController: ARShootingController,
        motionDetector: WeaponControlMotionDetector,
        viewModel: GameViewModel
    ) {
        self.arController = arController
        self.motionDetector = motionDetector
        self.viewModel = viewModel
        connectDependencyCallbacksToViewModel()
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack(alignment: .center) {
            // ARコンテンツ部分
            arController.view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    // タイムカウント
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundStyle(Color.goldLeaf.opacity(0.7))
                        .frame(width: 120, height: 50, alignment: .center)
                        .overlay {
                            Text(viewModel.timeCount.timeCountText)
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
                
                // 弾数画像
                HStack(spacing: 0) {
                    Image(viewModel.currentWeaponData?.bulletsCountImageName() ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 210, height: 70, alignment: .bottom)
                    
                    Spacer()
                }
            }
            
            // 照準画像
            Image(viewModel.currentWeaponData?.resources.sightImageName ?? "")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundStyle(ColorTypeConverter.fromColorType(viewModel.currentWeaponData?.resources.sightImageColorType ?? .red))
        }
        .onAppear {
            viewModel.onViewAppear()
        }
        .onDisappear {
            viewModel.onViewDisappear()
        }
        .onReceive(viewModel.arControllerInputEvent) { eventType in
            switch eventType {
            case .runSceneSession:
                arController.runSession()
            case .pauseSceneSession:
                arController.pauseSession()
            case .renderWeaponFiring:
                arController.renderWeaponFiring()
            case .showWeaponObject(let weaponId):
                arController.showWeaponObject(weaponId: weaponId)
            case .changeTargetsAppearance(let imageName):
                arController.changeTargetsAppearance(to: imageName)
            }
        }
        .onReceive(viewModel.motionDetectorInputEvent) { eventType in
            switch eventType {
            case .startDeviceMotionDetection:
                motionDetector.startDetection()
            case .stopDeviceMotionDetection:
                motionDetector.stopDetection()
            }
        }
        .onReceive(viewModel.playSound) { soundType in
            SoundPlayer.shared.play(soundType)
        }
        // チュートリアル画面への遷移
        .sheet(
            isPresented: $viewModel.isTutorialViewPresented,
            onDismiss: {
                // チュートリアルの完了を通知
                viewModel.tutorialEnded()
            }
        ) {
            ZStack(alignment: .center) {
                Color.black.opacity(0.7)
                UIBlurEffectViewRepresentable()
                TutorialViewFactory.create()
            }
            .ignoresSafeArea()
            // sheetの背景を透過
            .presentationBackground(.clear)
        }
        // 武器選択画面に遷移
        .sheet(isPresented: $viewModel.isWeaponSelectViewPresented) {
            WeaponSelectViewFactory.create(
                initialDisplayWeaponId: viewModel.currentWeaponData?.id ?? 0,
                weaponSelected: { weaponId in
                    viewModel.weaponSelected(weaponId: weaponId)
                }
            )
            // sheetの背景を透過
            .presentationBackground(.clear)
            .ignoresSafeArea()
        }
        // 結果画面に遷移
        .sheet(isPresented: $viewModel.isResultViewPresented) {
            ResultViewFactory.create(
                score: viewModel.score,
                replayButtonTapped: {
                    resetAllAndRestartGame()
                },
                toHomeButtonTapped: {
                    dismiss()
                }
            )
        }
        .errorAlert(
            viewModel.error.error,
            isPresented: $viewModel.error.isAlertPresented
        )
        .id(gameViewId)
    }
    
    private func connectDependencyCallbacksToViewModel() {
        arController.targetHit = {
            viewModel.targetHit()
        }
        motionDetector.fireMotionDetected = {
            viewModel.fireMotionDetected()
        }
        motionDetector.reloadMotionDetected = {
            viewModel.reloadMotionDetected()
        }
    }
    
    private func resetAllAndRestartGame() {
        // 依存を初期化し直してリセット
        let arController = ARShootingController(frame: .zero)
        let motionDetector = WeaponControlMotionDetector()
        let viewModel = GameViewModel(
            tutorialRepository: RepositoryFactory.create(),
            gameTimerCreateUseCase: UseCaseFactory.create(),
            weaponResourceGetUseCase: UseCaseFactory.create(),
            weaponActionExecuteUseCase: UseCaseFactory.create()
        )
        self.arController = arController
        self.motionDetector = motionDetector
        self.viewModel = viewModel
        // 依存先からのコールバックをVMに接続しなおし
        connectDependencyCallbacksToViewModel()
        // ルート階層のidを更新してビューを丸ごと再描画し、onAppearを呼ばせることでゲームをリスタートさせる
        gameViewId = UUID()
    }
}

#Preview {
    GameViewFactory.create(frame: .zero)
}
