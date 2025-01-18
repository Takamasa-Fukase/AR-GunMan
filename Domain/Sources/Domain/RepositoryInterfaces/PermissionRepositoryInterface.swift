//
//  PermissionRepositoryInterface.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation

public protocol PermissionRepositoryInterface {
    func getCameraUsagePermissionGrantedFlag() -> Bool
    func requestCameraUsagePermission()
}
