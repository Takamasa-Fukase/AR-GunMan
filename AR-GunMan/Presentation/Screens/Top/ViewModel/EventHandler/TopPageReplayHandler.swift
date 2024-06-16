//
//  TopPageReplayHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/6/24.
//

import RxSwift
import RxCocoa

final class TopPageReplayHandler: ViewModelEventHandlerType {
    struct Input {
        let checkNeedsReplay: Observable<Void>
    }
    
    struct Output {
        let setNeedsReplayFlagToFalse: Observable<Void>
        let showGameForReplay: Observable<Void>
    }
    
    private let topUseCase: TopUseCaseInterface
    
    init(topUseCase: TopUseCaseInterface) {
        self.topUseCase = topUseCase
    }
    
    func transform(input: Input) -> Output {
        let needsReplay = input.checkNeedsReplay
            .flatMapLatest({ [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.topUseCase.getNeedsReplay()
            })
            .filter({ $0 })
            .mapToVoid()
            .share()
        
        return Output(
            setNeedsReplayFlagToFalse: needsReplay,
            showGameForReplay: needsReplay
        )
    }
}
