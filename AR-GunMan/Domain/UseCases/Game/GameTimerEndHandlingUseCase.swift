//
//  GameTimerEndHandlingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct GameTimerEndHandlingInput {
    let timerEnded: Observable<Void>
}

struct GameTimerEndHandlingOutput {
    let stopMotionDetection: Observable<Void>
    let dismissWeaponChangeView: Observable<Void>
    let showResultView: Observable<Void>
}

protocol GameTimerEndHandlingUseCaseInterface {
    func transform(input: GameTimerEndHandlingInput) -> GameTimerEndHandlingOutput
}

final class GameTimerEndHandlingUseCase: GameTimerEndHandlingUseCaseInterface {
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
    
    func transform(input: GameTimerEndHandlingInput) -> GameTimerEndHandlingOutput {
        let resultViewShowingWaitTimeEnded = input.timerEnded
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.timerStreamCreator
                    .create(
                        milliSec: GameConst.showResultWaitingTimeMillisec,
                        isRepeated: false
                    )
                    .mapToVoid()
            })
            .share()
        
        disposeBag.insert {
            resultViewShowingWaitTimeEnded
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    self.soundPlayer.play(.rankingAppear)
                })
        }
        
        return GameTimerEndHandlingOutput(
            stopMotionDetection: input.timerEnded,
            dismissWeaponChangeView: input.timerEnded,
            showResultView: resultViewShowingWaitTimeEnded
        )
    }
}
