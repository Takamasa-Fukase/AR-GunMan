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
    let timerEnded: Observable<Void>
}

protocol GameTimerHandlingUseCaseInterface {
    func transform(input: GameTimerHandlingInput) -> GameTimerHandlingOutput
}

final class GameTimerHandlingUseCase: GameTimerHandlingUseCaseInterface {
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
    
    func transform(input: GameTimerHandlingInput) -> GameTimerHandlingOutput {
        let updateTimeCountRelay = PublishRelay<Double>()
        let timerEndedRelay = PublishRelay<Void>()

        disposeBag.insert {
            input.timerStartTrigger
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    self.soundPlayer.play(.startWhistle)
                })
            input.timerStartTrigger
                .flatMapLatest({ [weak self] _ -> Observable<Double> in
                    guard let self = self else { return .empty() }
                    return self.timerStreamCreator
                        .create(
                            milliSec: GameConst.timeCountUpdateDurationMillisec,
                            isRepeated: true
                        )
                        .map({ timerUpdatedCount in // タイマーが更新された回数を表すInt
                            // 例: 30.00 - (1 / 100) => 29.99
                            return GameConst.timeCount - (Double(timerUpdatedCount) / 100)
                        })
                })
                .take(while: { $0 >= 0 }) // 条件がfalseになるとcompletedが呼ばれる
                .subscribe(
                    onNext: {
                        updateTimeCountRelay.accept($0)
                    },
                    onCompleted: { [weak self] in
                        guard let self = self else { return }
                        self.soundPlayer.play(.endWhistle)
                        timerEndedRelay.accept(())
                    }
                )
        }
        
        return GameTimerHandlingOutput(
            updateTimeCount: updateTimeCountRelay.asObservable(),
            timerEnded: timerEndedRelay.asObservable()
        )
    }
}
