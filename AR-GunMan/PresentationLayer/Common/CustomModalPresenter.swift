//
//  CustomTransitionView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 22/12/24.
//

import SwiftUI
import Combine

// モーダル表示コンテンツ内部からのdismissリクエストを受け取る為のレシーバー
final class DismissRequestReceiver {
    let subject = PassthroughSubject<Void, Never>()
}

struct CustomModalPresenter<ModalContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let dismissOnBackgroundTap: Bool
    let applyBlurEffectBackground: Bool
    let onDismiss: (() -> Void)?
    let modalContent: ModalContent
    let dismissRequestReceiver = DismissRequestReceiver()
    
    init(
        isPresented: Binding<Bool>,
        dismissOnBackgroundTap: Bool,
        applyBlurEffectBackground: Bool,
        onDismiss: (() -> Void)?,
        @ViewBuilder modalContent: ((DismissRequestReceiver) -> ModalContent)
    ) {
        self._isPresented = isPresented
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.applyBlurEffectBackground = applyBlurEffectBackground
        self.onDismiss = onDismiss
        // modalContentにレシーバーを受け渡し
        self.modalContent = modalContent(dismissRequestReceiver)
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            // モーダル表示元のビュー
            content
            
            // モーダルのコンテンツを上に被せる
            if isPresented {
                modalContent
                    .modifier(
                        CustomModalModifier(
                            dismissOnBackgroundTap: dismissOnBackgroundTap,
                            applyBlurEffectBackground: applyBlurEffectBackground,
                            onDismiss: {
                                onDismiss?()
                                isPresented = false
                            },
                            dismissRequestReceived: dismissRequestReceiver.subject
                        )
                    )
            }
        }
    }
}

struct CustomModalModifier: ViewModifier {
    let dismissOnBackgroundTap: Bool
    let applyBlurEffectBackground: Bool
    let onDismiss: (() -> Void)?
    let dismissRequestReceived: PassthroughSubject<Void, Never>
    @State private var backgroundOpacity: CGFloat = 0.0
    @State private var blurEffectOpacity: CGFloat = 0.0
    @State private var contentOffsetY: CGFloat = 0.0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // 背景の半透明ビュー（画面の表示＆非表示時で透明度をアニメーションで切り替える）
                Color.black
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture(perform: {
                        if dismissOnBackgroundTap {
                            executeTransitionAnimation(isAppearing: false, geometry) {
                                onDismiss?()
                            }
                        }
                    })
                
                // ぼかし効果のビューを表示するオプションが有効の場合のみ表示（タップ判定は無効にして透過する）
                if applyBlurEffectBackground {
                    UIBlurEffectViewRepresentable()
                        .allowsHitTesting(false)
                        .opacity(blurEffectOpacity)
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                                
                // モーダル表示するコンテンツ（Y座標を表示＆非表示時でアニメーションで切り替える）
                content
                    .offset(y: contentOffsetY)
            }
            .onAppear {
                executeTransitionAnimation(isAppearing: true, geometry)
            }
            .onReceive(dismissRequestReceived) {
                executeTransitionAnimation(isAppearing: false, geometry) {
                    onDismiss?()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func executeTransitionAnimation(isAppearing: Bool, _ geometry: GeometryProxy, completion: (() -> Void)? = nil) {
        let duration: TimeInterval = 0.16
        // 表示開始時の処理
        if isAppearing {
            contentOffsetY = geometry.size.height
            withAnimation(.linear(duration: duration)) {
                backgroundOpacity = 0.7
                blurEffectOpacity = 1.0
                contentOffsetY = 0
            }
        }
        // 表示終了時の処理
        else {
            withAnimation(.linear(duration: duration)) {
                backgroundOpacity = 0.0
                blurEffectOpacity = 0.0
                contentOffsetY = geometry.size.height
            } completion: {
                completion?()
            }
        }
    }
}

extension View {
    func showCustomModal<ModalContent: View>(
        isPresented: Binding<Bool>,
        dismissOnBackgroundTap: Bool = true,
        applyBlurEffectBackground: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder modalContent: ((DismissRequestReceiver) -> ModalContent)
    ) -> some View {
        modifier(CustomModalPresenter(
            isPresented: isPresented,
            dismissOnBackgroundTap: dismissOnBackgroundTap,
            applyBlurEffectBackground: applyBlurEffectBackground,
            onDismiss: onDismiss,
            modalContent: modalContent
        ))
    }
}


// MARK: Preview用のビュー
struct CustomModalPreviewView: View {
    @State var isPresented = false
    
    var body: some View {
        ZStack(alignment: .center, content: {
            Color.goldLeaf
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: {
                isPresented = true
            }, label: {
                Text("show")
            })
        })
        .ignoresSafeArea()
        .showCustomModal(
            isPresented: $isPresented,
            onDismiss: {
                
            }) { dismissRequest in
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.orange)
                    .frame(width: 400, height: 300)
                    .presentationBackground(.clear)
            }
    }
}

#Preview {
    CustomModalPreviewView()
}
