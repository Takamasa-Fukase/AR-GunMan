//
//  DummyCMData.swift.swift
//  WeaponControlMotionTests
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation
import CoreMotion

final class DummyCMAccelerometerData: CMAccelerometerData {
    var dummyAcceleration: CMAcceleration
    override var acceleration: CMAcceleration {
        return dummyAcceleration
    }
    
    init(x: Double, y: Double, z: Double) {
        self.dummyAcceleration = .init(x: x, y: y, z: z)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class DummyCMGyroData: CMGyroData {
    var dummyRotationRate: CMRotationRate
    override var rotationRate: CMRotationRate {
        return dummyRotationRate
    }
    
    init(x: Double, y: Double, z: Double) {
        self.dummyRotationRate = .init(x: x, y: y, z: z)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
