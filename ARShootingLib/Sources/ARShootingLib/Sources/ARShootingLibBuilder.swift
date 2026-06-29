//
//  ARShootingLibBuilder.swift
//  ARShootingLib
//
//  Created by ウルトラ深瀬 on 2026/06/14.
//

import Foundation

public struct ARShootingLibBuilder {
    public static func build(
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
