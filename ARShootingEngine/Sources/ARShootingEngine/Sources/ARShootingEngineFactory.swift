//
//  ARShootingEngineFactory.swift
//  ARShootingEngine
//
//  Created by ウルトラ深瀬 on 2026/06/14.
//

import Foundation

public struct ARShootingEngineFactory {
    public static func create(
        frame: CGRect,
        targetCount: Int
    ) -> (ARShootingControllerInterface, ARSCNViewRepresentable) {
        let controller = ARShootingController(
            frame: frame,
            targetCount: targetCount
        )
        let arView = ARSCNViewRepresentable(view: controller.arView)
        return (controller, arView)
    }
}
