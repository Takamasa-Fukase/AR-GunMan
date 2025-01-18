//
//  ContentFrameTrackableScrollView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/11/24.
//

import SwiftUI

struct ContentFrameTrackableScrollView<Content: View>: View {
    let scrollDirections: Axis.Set
    let showsIndicator: Bool
    let content: Content
    let onScroll: (CGRect) -> Void
    
    init(
        scrollDirections: Axis.Set,
        showsIndicator: Bool = true,
        @ViewBuilder content: () -> Content,
        onScroll: @escaping (CGRect) -> Void
    ) {
        self.scrollDirections = scrollDirections
        self.showsIndicator = showsIndicator
        self.content = content()
        self.onScroll = onScroll
    }
    
    var body: some View {
        return ScrollView(
            scrollDirections,
            showsIndicators: showsIndicator
        ) {
            content.background {
                GeometryReader { geometry in
                    Color.clear.onChange(of: geometry.frame(in: .scrollView), { _, newFrame in
                        onScroll(newFrame)
                    })
                }
            }
        }
    }
}
