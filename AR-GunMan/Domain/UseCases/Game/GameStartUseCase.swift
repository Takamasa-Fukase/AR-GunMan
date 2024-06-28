//
//  GameStartUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct GameStartInput {
    let trigger: Observable<Void>
}

struct GameStartOutput {
    let startMotionDetection: Observable<Void>
    let startTimer: Observable<Void>
}

protocol GameStartUseCaseInterface {
    func transform(input: GameStartInput) -> GameStartOutput
}

final class GameStartUseCase: GameStartUseCaseInterface {
    private let timerStreamCreator: TimerStreamCreator
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(
        timerStreamCreator: TimerStreamCreator = TimerStreamCreator(),
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared
    ) {
        self.timerStreamCreator = timerStreamCreator
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: GameStartInput) -> GameStartOutput {
        let timerStartWaitTimeEnded = input.trigger
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.timerStreamCreator
                    .create(
                        milliSec: GameConst.timerStartWaitingTimeMillisec,
                        isRepeated: false
                    )
                    .mapToVoid()
            })
            .share()
        
        disposeBag.insert {
            input.trigger
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    self.soundPlayer.play(.pistolSet)
                })
        }
        
        return GameStartOutput(
            startMotionDetection: timerStartWaitTimeEnded,
            startTimer: timerStartWaitTimeEnded
        )
    }
}
