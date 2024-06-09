//
//  Vector.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/6/24.
//

import Foundation
import SceneKit

struct Vector {
    let x: Double
    let y: Double
    let z: Double
    
    var sceneVector3: SCNVector3 {
        return SCNVector3(x: Float(x), y: Float(y), z: Float(z))
    }
}

extension SCNVector3 {
    var vector: Vector {
        return Vector(x: Double(x), y: Double(y), z: Double(z))
    }
}
