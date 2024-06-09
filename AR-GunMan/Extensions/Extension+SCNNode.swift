//
//  Extension+SCNNode.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/6/24.
//

import SceneKit

extension SCNVector3 {
    var vector: Vector {
        return Vector(x: Double(x), y: Double(y), z: Double(z))
    }
}
