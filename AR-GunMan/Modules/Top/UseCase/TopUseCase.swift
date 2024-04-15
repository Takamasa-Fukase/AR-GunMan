//
//  TopUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/15.
//

import RxSwift

class TopUseCase {
    private let avPermissionRepository: AVPermissionRepository
    
    init(avPermissionRepository: AVPermissionRepository) {
        self.avPermissionRepository = avPermissionRepository
    }
    
    func getIsPermittedCameraAccess() -> Observable<Bool> {
        return avPermissionRepository.getIsPermittedCameraAccess()
    }
}
