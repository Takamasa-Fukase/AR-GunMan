//
//  AVPermissionRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/15.
//

import AVFoundation
import RxSwift

final class AVPermissionRepository {
    func getIsPermittedCameraAccess() -> Observable<Bool> {
        return Observable.just(
            AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        )
    }
}
