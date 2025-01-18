//
//  ARShootingView.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 15/12/24.
//

import ARKit
import SwiftUI

struct SceneViewRepresentable: UIViewRepresentable {
    private let view: ARSCNView
    
    init(view: ARSCNView) {
        self.view = view
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        return view
    }
    
    func updateUIView(_ view: ARSCNView, context: Context) {}
    
    // MARK: ユニットテスト時のみアクセスする
    #if DEBUG
    func getView() -> ARSCNView {
        return view
    }
    #endif
}
