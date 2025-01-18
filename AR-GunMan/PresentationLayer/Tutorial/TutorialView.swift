//
//  TutorialView.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import SwiftUI

struct TutorialView: View {
    @State var viewModel: TutorialViewModel
    @State var dismissRequestReceiver: DismissRequestReceiver?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                ScrollViewReader { proxy in
                    // 横向きのスクロールビュー（PagerView的な）
                    ContentFrameTrackableScrollView(
                        scrollDirections: .horizontal,
                        showsIndicator: false,
                        content: {
                            HStack(spacing: 0) {
                                ForEach(Array(viewModel.contents.enumerated()), id: \.offset) { index, content in
                                    TutorialScrollViewItem(content: content)
                                        .id(index) // 指定したページにスクロールできる様に識別idを付与
                                        .frame(width: geometry.size.height * 0.65 * 1.33)
                                }
                            }
                        },
                        onScroll: { contentFrame in
                            viewModel.onScroll(contentFrame)
                        }
                    )
                    // ページング可能にする（ピッタリ止まる）
                    .scrollTargetBehavior(.paging)
                    .frame(width: geometry.size.height * 0.65 * 1.33)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.goldLeaf, lineWidth: 5)
                    }
                    .onReceive(viewModel.scrollToPageIndex) { pageIndex in
                        // 受け取ったpageIndexまでアニメーション付きでスクロールさせる
                        withAnimation {
                            proxy.scrollTo(pageIndex)
                        }
                    }
                }
                
                // ページインジケーター
                HStack(alignment: .center, spacing: 0) {
                    ForEach(0..<viewModel.contents.count, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundStyle(
                                index == viewModel.currentPageIndex ? Color.paper : Color(.lightGray)
                            )
                            .clipped()
                            .padding(.all, 4)
                    }
                }
                .frame(height: 30)
                
                // 画面下部のボタン（NEXT or OK）
                Button {
                    viewModel.buttonTapped()
                } label: {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color.goldLeaf)
                        .frame(width: 150, height: 65, alignment: .center)
                        .overlay {
                            Text(viewModel.buttonTitle)
                                .font(.custom("Copperplate Bold", size: 25))
                                .foregroundStyle(Color.blackSteel)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.customDarkBrown, lineWidth: 1)
                        }
                }
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 24, trailing: 0))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onReceive(viewModel.dismiss) {
            if let dismissRequestReceiver = dismissRequestReceiver {
                dismissRequestReceiver.subject.send(())
            }else {
                dismiss()
            }
        }
    }
}

#Preview {
    TutorialViewFactory.create()
}
