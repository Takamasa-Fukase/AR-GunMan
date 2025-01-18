//
//  PermissionRepository.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation
import AVFoundation
import DomainLayer

public final class PermissionRepository: PermissionRepositoryInterface {
    public init() {}

    public func getCameraUsagePermissionGrantedFlag() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    public func requestCameraUsagePermission() {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
    }
}
