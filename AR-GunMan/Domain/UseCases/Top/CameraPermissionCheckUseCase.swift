//
//  CameraPermissionCheckUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa
import AVFoundation

struct CameraPermissionCheckInput {
    let checkIsCameraAccessPermitted: Observable<Void>
}

struct CameraPermissionCheckOutput {
    let showGame: Observable<Void>
    let showCameraPermissionDescriptionAlert: Observable<Void>
}

protocol CameraPermissionCheckUseCaseInterface {
    func generateOutput(from input: CameraPermissionCheckInput) -> CameraPermissionCheckOutput
}

final class CameraPermissionCheckUseCase: CameraPermissionCheckUseCaseInterface {
    func generateOutput(from input: CameraPermissionCheckInput) -> CameraPermissionCheckOutput {
        let isPermitted = input.checkIsCameraAccessPermitted
            .map({ AVCaptureDevice.authorizationStatus(for: .video) == .authorized })
            .share()
        
        let showGame = isPermitted
            .filter({ $0 })
            .mapToVoid()

        let showCameraPermissionDescriptionAlert = isPermitted
            .filter({ !$0 })
            .mapToVoid()

        return CameraPermissionCheckOutput(
            showGame: showGame,
            showCameraPermissionDescriptionAlert: showCameraPermissionDescriptionAlert
        )
    }
}
