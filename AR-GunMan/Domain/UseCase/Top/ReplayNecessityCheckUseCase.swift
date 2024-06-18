//
//  ReplayNecessityCheckUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct ReplayNecessityCheckInput {
    let checkNeedsReplay: Observable<Void>
}

struct ReplayNecessityCheckOutput {
    let showGameForReplay: Observable<Void>
}

protocol ReplayNecessityCheckUseCaseInterface {
    func transform(input: ReplayNecessityCheckInput) -> ReplayNecessityCheckOutput
}

final class ReplayNecessityCheckUseCase: ReplayNecessityCheckUseCaseInterface {
    private let replayRepository: ReplayRepositoryInterface

    init(replayRepository: ReplayRepositoryInterface) {
        self.replayRepository = replayRepository
    }
    
    func transform(input: ReplayNecessityCheckInput) -> ReplayNecessityCheckOutput {
        let showGameForReplay = input.checkNeedsReplay
            .flatMapLatest({ [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.replayRepository.getNeedsReplay()
            })
            .filter({ $0 })
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.replayRepository.setNeedsReplay(false)
            })
        
        return ReplayNecessityCheckOutput(
            showGameForReplay: showGameForReplay
        )
    }
}
