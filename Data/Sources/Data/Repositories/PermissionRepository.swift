//
//  PermissionRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation
import Domain

public final class PermissionRepository: PermissionRepositoryInterface {
    private let cameraPermissionHandler: CameraPermissionHandlerInterface
    
    public init(cameraPermissionHandler: CameraPermissionHandlerInterface) {
        self.cameraPermissionHandler = cameraPermissionHandler
    }

    public func getCameraUsagePermissionGrantedFlag() -> Bool {
        return cameraPermissionHandler.getCameraUsagePermissionGrantedFlag()
    }
    
    public func requestCameraUsagePermission() {
        cameraPermissionHandler.requestCameraUsagePermission()
    }
}
