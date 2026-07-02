//
//  CoreMotionHandlerInterface.swift
//  Devices
//
//  Created by ウルトラ深瀬 on 2026/06/05.
//

import Foundation
import Domain

public protocol CoreMotionHandlerInterface: AnyObject {
    var accelerationUpdated: ((VectorMotionData) -> Void)? { get set }
    var gyroUpdated: ((VectorMotionData) -> Void)? { get set }
    func startDetection()
    func stopDetection()
}
