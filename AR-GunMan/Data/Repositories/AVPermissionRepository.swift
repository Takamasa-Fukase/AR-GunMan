//
//  AVPermissionRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/15.
//

import AVFoundation
import RxSwift

protocol AVPermissionRepositoryInterface {
    func getIsCameraAccessPermitted() -> Observable<Bool>
}

final class AVPermissionRepository: AVPermissionRepositoryInterface {
    func getIsCameraAccessPermitted() -> Observable<Bool> {
        return Observable.just(
            AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        )
    }
}
