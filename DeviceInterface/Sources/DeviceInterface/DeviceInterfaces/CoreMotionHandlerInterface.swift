//
//  CoreMotionHandlerInterface.swift
//  DeviceInterface
//
//  Created by ウルトラ深瀬 on 2026/06/05.
//

import Foundation
import Domain

public protocol CoreMotionHandlerInterface: AnyObject {
    var motionUpdated: ((Motion) -> Void)? { get set }
    func startDetection()
    func stopDetection()
}
