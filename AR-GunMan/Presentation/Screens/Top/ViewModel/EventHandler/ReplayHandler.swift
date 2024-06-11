//
//  ReplayHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/6/24.
//

import RxSwift
import RxCocoa

final class ReplayHandler: ViewModelEventHandlerType {
    struct Input {
        let checkNeedsReplay: Observable<Void>
    }
    
    struct Output {
        let setNeedsReplayToFalse: Observable<Void>
        let showGameForReplay: Observable<Void>
    }
    
    private let topUseCase: TopUseCaseInterface2
    
    init(topUseCase: TopUseCaseInterface2) {
        self.topUseCase = topUseCase
    }
    
    func transform(input: Input) -> Output {
        let needsReplay = input.checkNeedsReplay
            .flatMapLatest({ [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.topUseCase.getNeedsReplay()
            })
            .filter({ $0 })
            .map({ _ in })
            .share()
        
        return Output(
            setNeedsReplayToFalse: needsReplay,
            showGameForReplay: needsReplay
        )
    }
}
