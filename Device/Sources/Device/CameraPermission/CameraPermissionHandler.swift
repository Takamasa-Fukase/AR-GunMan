//
//  CameraPermissionHandler.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/06/08.
//

import Foundation
import AVFoundation
import DeviceInterface

public final class CameraPermissionHandler: CameraPermissionHandlerInterface {
    public init() {}
    
    public func getCameraUsagePermissionGrantedFlag() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    public func requestCameraUsagePermission() {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
    }
}
