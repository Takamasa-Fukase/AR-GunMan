//
//  CenterPreviewView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import SwiftUI

struct CenterPreviewView<Content: View>: View {
    let backgroundColor: Color
    let content: Content
    
    init(
        backgroundColor: Color = .white,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
            content
        }
        .background(backgroundColor)
    }
}
