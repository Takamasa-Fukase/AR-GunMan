//
//  CameraPermissionCheckUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct CameraPermissionCheckInput {
    let checkIsCameraAccessPermitted: Observable<Void>
}

struct CameraPermissionCheckOutput {
    let showGame: Observable<Void>
    let showCameraPermissionDescriptionAlert: Observable<Void>
}

protocol CameraPermissionCheckUseCaseInterface {
    func transform(input: CameraPermissionCheckInput) -> CameraPermissionCheckOutput
}

final class CameraPermissionCheckUseCase: CameraPermissionCheckUseCaseInterface {
    private let avPermissionRepository: AVPermissionRepositoryInterface
    
    init(avPermissionRepository: AVPermissionRepositoryInterface) {
        self.avPermissionRepository = avPermissionRepository
    }
    
    func transform(input: CameraPermissionCheckInput) -> CameraPermissionCheckOutput {
        let isPermitted = input.checkIsCameraAccessPermitted
            .flatMapLatest({ [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.avPermissionRepository.getIsCameraAccessPermitted()
            })
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
