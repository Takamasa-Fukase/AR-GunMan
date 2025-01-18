//
//  CameraUsagePermissionHandlingUseCase.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation

public protocol CameraUsagePermissionHandlingUseCaseInterface {
    func checkGrantedFlag() -> Bool
    func requestPermission()
}

public final class CameraUsagePermissionHandlingUseCase: CameraUsagePermissionHandlingUseCaseInterface {
    private let permissionRepository: PermissionRepositoryInterface
    
    public init(permissionRepository: PermissionRepositoryInterface) {
        self.permissionRepository = permissionRepository
    }
    
    public func checkGrantedFlag() -> Bool {
        return permissionRepository.getCameraUsagePermissionGrantedFlag()
    }
    
    public func requestPermission() {
        permissionRepository.requestCameraUsagePermission()
    }
}
