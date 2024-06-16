//
//  CameraPermissionHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/6/24.
//

import RxSwift
import RxCocoa

final class CameraPermissionHandler: ViewModelEventHandlerType {
    struct Input {
        let checkIsCameraAccessPermitted: Observable<Void>
    }
    
    struct Output {
        let showGame: Observable<Void>
        let showCameraPermissionDescriptionAlert: Observable<Void>
    }
    
    private let topUseCase: TopUseCaseInterface
    
    init(topUseCase: TopUseCaseInterface) {
        self.topUseCase = topUseCase
    }
    
    func transform(input: Input) -> Output {
        let isPermitted = input.checkIsCameraAccessPermitted
            .flatMapLatest({ [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.topUseCase.getIsCameraAccessPermitted()
            })
            .share()
        
        let showGame = isPermitted
            .filter({ $0 })
            .mapToVoid()

        let showCameraPermissionDescriptionAlert = isPermitted
            .filter({ !$0 })
            .mapToVoid()

        return Output(
            showGame: showGame,
            showCameraPermissionDescriptionAlert: showCameraPermissionDescriptionAlert
        )
    }
}
