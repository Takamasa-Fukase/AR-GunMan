//
//  PermissionRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation
import AVFoundation
import Domain

public final class PermissionRepository: PermissionRepositoryInterface {
    public init() {}

    public func getCameraUsagePermissionGrantedFlag() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    public func requestCameraUsagePermission() {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
    }
}
