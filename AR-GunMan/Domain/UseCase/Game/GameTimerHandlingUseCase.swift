//
//  GameTimerHandlingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct GameTimerHandlingInput {
    let timerStartTrigger: Observable<Void>
}

struct GameTimerHandlingOutput {
    let updateTimeCount: Observable<Double>
    let disposeTimer: Observable<Void>
}

protocol GameTimerHandlingUseCaseInterface {
    func transform(input: GameTimerHandlingInput) -> GameTimerHandlingOutput
}

final class GameTimerHandlingUseCase: GameTimerHandlingUseCaseInterface {
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: GameTimerHandlingInput) -> GameTimerHandlingOutput {
        let timeCountStream = input.timerStartTrigger
            .flatMapLatest({ _ in
                return TimerStreamCreator
                    .create(
                        milliSec: GameConst.timeCountUpdateDurationMillisec,
                        isRepeated: true
                    )
                    .map({ timerUpdatedCount in // タイマーが更新された回数を表すInt
                        // 例: 30.00 - (1 / 100) => 29.99
                        return GameConst.timeCount - (Double(timerUpdatedCount) / 100)
                    })
            })
            .share()
        
        let timeCountEnded = timeCountStream
            .filter({ $0 < 0 })
            .mapToVoid()
            .share()
        
        disposeBag.insert {
            input.timerStartTrigger
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    self.soundPlayer.play(.startWhistle)
                })
            timeCountEnded
                .subscribe(onNext: { [weak self] element in
                    guard let self = self else {return}
                    self.soundPlayer.play(.endWhistle)
                })
        }
        
        return GameTimerHandlingOutput(
            updateTimeCount: timeCountStream,
            disposeTimer: timeCountEnded
        )
    }
}
