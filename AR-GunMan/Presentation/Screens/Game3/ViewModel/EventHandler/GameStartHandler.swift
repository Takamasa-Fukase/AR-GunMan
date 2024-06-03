//
//  GameStartHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 1/6/24.
//

import RxSwift
import RxCocoa

final class GameStartHandler {
    struct Input {
        let gameStarted: Observable<Void>
    }
    
    struct Output {
        let playPistolSetSound: Observable<SoundType>
        let startMotionDetection: Observable<Void>
        let startTimer: Observable<Void>
    }
    
    private let gameUseCase: GameUseCase2Interface
    
    init(gameUseCase: GameUseCase2Interface) {
        self.gameUseCase = gameUseCase
    }
    
    func transform(input: Input) -> Output {
        let timerStartSignalReceived = input.gameStarted
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.gameUseCase.awaitTimerStartSignal()
            })
            .share()
        
        return Output(
            playPistolSetSound: input.gameStarted.map({ _ in .pistolSet }),
            startMotionDetection: timerStartSignalReceived,
            startTimer: timerStartSignalReceived
        )
    }
}
