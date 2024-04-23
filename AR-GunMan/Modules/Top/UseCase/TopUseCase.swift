//
//  TopUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/15.
//

import RxSwift

final class TopUseCase {
    private let avPermissionRepository: AVPermissionRepository
    private let replayRepository: ReplayRepository
    
    init(
        avPermissionRepository: AVPermissionRepository,
        replayRepository: ReplayRepository
    ) {
        self.avPermissionRepository = avPermissionRepository
        self.replayRepository = replayRepository
    }
    
    func getIsPermittedCameraAccess() -> Observable<Bool> {
        return avPermissionRepository.getIsPermittedCameraAccess()
    }
    
    func getNeedsReplay() -> Observable<Bool> {
        return replayRepository.getNeedsReplay()
    }
    
    func setNeedsReplay(_ newValue: Bool) {
        replayRepository.setNeedsReplay(newValue)
    }
}
