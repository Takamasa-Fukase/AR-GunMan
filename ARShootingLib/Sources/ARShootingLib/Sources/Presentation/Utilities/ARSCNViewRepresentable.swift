//
//  ARSCNViewRepresentable.swift
//  ARShooting
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import ARKit
import SwiftUI

public struct ARSCNViewRepresentable: UIViewRepresentable {
    private let view: ARSCNView
    
    public init(view: AnyObject?) {
        self.view = view as! ARSCNView
    }
    
    public func makeUIView(context: Context) -> ARSCNView {
        return view
    }
    
    public func updateUIView(_ view: ARSCNView, context: Context) {}
}

extension ARSCNViewRepresentable {
    // MARK: ユニットテスト時のみアクセスする
    #if DEBUG
    public func getView() -> ARSCNView {
        return view
    }
    #endif
    
    public static func createMock() -> ARSCNViewRepresentable {
        return .init(view: ARSCNView(frame: .zero))
    }
}
