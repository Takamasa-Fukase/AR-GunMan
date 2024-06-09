//
//  Vector.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 9/6/24.
//

import Foundation

struct Vector {
    let x: Double
    let y: Double
    let z: Double
    
    var sceneVector3: SCNVector3 {
        return SCNVector3(x: Float(x), y: Float(y), z: Float(z))
    }
}
