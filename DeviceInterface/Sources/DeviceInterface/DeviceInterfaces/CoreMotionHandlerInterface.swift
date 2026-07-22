//
//  CoreMotionHandlerInterface.swift
//  DeviceInterface
//
//  Created by ウルトラ深瀬 on 2026/06/05.
//

import Foundation
import Domain

public protocol CoreMotionHandlerInterface: AnyObject {
    var accelerationUpdated: ((Vector) -> Void)? { get set }
    var gyroUpdated: ((Vector) -> Void)? { get set }
    func startDetection()
    func stopDetection()
}
