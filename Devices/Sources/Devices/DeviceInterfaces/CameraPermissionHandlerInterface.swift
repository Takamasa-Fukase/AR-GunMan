//
//  CameraPermissionHandlerInterface.swift
//  Devices
//
//  Created by ウルトラ深瀬 on 2026/06/08.
//

import Foundation

public protocol CameraPermissionHandlerInterface {
    func getCameraUsagePermissionGrantedFlag() -> Bool
    func requestCameraUsagePermission()
}
