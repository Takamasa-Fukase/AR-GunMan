//
//  UIBlurEffectViewRepresentable.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 22/12/24.
//

import SwiftUI

struct UIBlurEffectViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        return visualEffectView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
