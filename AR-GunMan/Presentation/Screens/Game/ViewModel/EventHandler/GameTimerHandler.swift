//
//  GameTimerHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 1/6/24.
//

import RxSwift
import RxCocoa

final class GameTimerHandler {
    struct Input {
        let timerStartTrigger: Observable<Void>
    }
    
    struct Output {
        let playStartWhistleSound: Observable<SoundType>
        let playEndWhistleSound: Observable<SoundType>
        let updateTimeCount: Observable<Double>
        let disposeTimer: Observable<Void>
    }
    
    private let gameUseCase: GameUseCaseInterface
    
    init(gameUseCase: GameUseCaseInterface) {
        self.gameUseCase = gameUseCase
    }
    
    func transform(input: Input) -> Output {
        let playStartWhistleSoundRelay = PublishRelay<SoundType>()
        let playEndWhistleSoundRelay = PublishRelay<SoundType>()
        let disposeTimerRelay = PublishRelay<Void>()
            
        let updateTimeCount = input.timerStartTrigger
            .do(onNext: { _ in
                playStartWhistleSoundRelay.accept(.startWhistle)
            })
            .flatMapLatest({ [weak self] _ -> Observable<Double> in
                guard let self = self else { return .empty() }
                return self.gameUseCase.getTimeCountStream()
            })
            .do(onNext: { timeCount in
                if timeCount < 0 {
                    playEndWhistleSoundRelay.accept(.endWhistle)
                    disposeTimerRelay.accept(Void())
                }
            })
        
        return Output(
            playStartWhistleSound: playStartWhistleSoundRelay.asObservable(),
            playEndWhistleSound: playEndWhistleSoundRelay.asObservable(),
            updateTimeCount: updateTimeCount,
            disposeTimer: disposeTimerRelay.asObservable()
        )
    }
}
