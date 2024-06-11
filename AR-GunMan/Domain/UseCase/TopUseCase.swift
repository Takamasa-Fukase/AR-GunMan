//
//  TopUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/6/24.
//

import RxSwift

protocol TopUseCaseInterface {
    func getIsCameraAccessPermitted() -> Observable<Bool>
    func getNeedsReplay() -> Observable<Bool>
    func setNeedsReplay(_ newValue: Bool) -> Observable<Void>
    func awaitIconRevertSignal() -> Observable<Void>
}

final class TopUseCase: TopUseCaseInterface {
    private let avPermissionRepository: AVPermissionRepositoryInterface
    private let replayRepository: ReplayRepositoryInterface
    private let timerRepository: TimerRepositoryInterface
    
    init(
        avPermissionRepository: AVPermissionRepositoryInterface,
        replayRepository: ReplayRepositoryInterface,
        timerRepository: TimerRepositoryInterface
    ) {
        self.avPermissionRepository = avPermissionRepository
        self.replayRepository = replayRepository
        self.timerRepository = timerRepository
    }
    
    func getIsCameraAccessPermitted() -> Observable<Bool> {
        // TODO: 後でrepoも命名を合わせる
        return avPermissionRepository.getIsPermittedCameraAccess()
    }
    
    func getNeedsReplay() -> Observable<Bool> {
        return replayRepository.getNeedsReplay()
    }
    
    func setNeedsReplay(_ newValue: Bool) -> Observable<Void> {
        return replayRepository.setNeedsReplay(newValue)
    }
    
    func awaitIconRevertSignal() -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: TopConst.iconRevertWaitingTimeMillisec,
                isRepeated: false
            )
            .map({ _ in })
    }
}

