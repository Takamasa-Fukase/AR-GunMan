//
//  ARSCNViewRepresentable.swift
//  ARShooting
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import ARKit
import SwiftUI

struct ARSCNViewRepresentable: UIViewRepresentable {
    private let view: ARSCNView
    
    init(view: AnyObject?) {
        self.view = view as! ARSCNView
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
