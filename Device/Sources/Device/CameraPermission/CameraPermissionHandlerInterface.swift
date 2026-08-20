//
//  CameraPermissionHandlerInterface.swift
//  DeviceInterface
//
//  Created by ウルトラ深瀬 on 2026/06/08.
//

import Foundation

public protocol CameraPermissionHandlerInterface: AnyObject {
    func getCameraUsagePermissionGrantedFlag() -> Bool
    func requestCameraUsagePermission()
}
