//
//  GameTimerDisposalHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 3/6/24.
//

import RxSwift
import RxCocoa

final class GameTimerDisposalHandler {
    struct Input {
        let timerDisposed: Observable<Void>
    }
    
    struct Output {
        let stopMotionDetection: Observable<Void>
        let dismissWeaponChangeView: Observable<Void>
        let playRankingAppearSound: Observable<SoundType>
        let showResultView: Observable<Void>
    }
    
    private let gameUseCase: GameUseCaseInterface
    
    init(gameUseCase: GameUseCaseInterface) {
        self.gameUseCase = gameUseCase
    }
    
    func transform(input: Input) -> Output {
        let resultViewShowingSignalReceived = input.timerDisposed
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.gameUseCase.awaitShowResultSignal()
            })
            .share()
        
        return Output(
            stopMotionDetection: input.timerDisposed,
            dismissWeaponChangeView: input.timerDisposed,
            playRankingAppearSound: resultViewShowingSignalReceived
                .map({ _ in .rankingAppear }),
            showResultView: resultViewShowingSignalReceived
        )
    }
}
