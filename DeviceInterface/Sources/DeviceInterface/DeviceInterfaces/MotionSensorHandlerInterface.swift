//
//  MotionSensorHandlerInterface.swift
//  DeviceInterface
//
//  Created by ウルトラ深瀬 on 2026/06/05.
//

import Foundation
import Domain

public protocol MotionSensorHandlerInterface: AnyObject {
    var motionUpdated: ((PhysicalMotion) -> Void)? { get set }
    func startDetection()
    func stopDetection()
}
