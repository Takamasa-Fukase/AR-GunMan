//
//  GameTimerDisposalHandlingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct GameTimerDisposalHandlingInput {
    let timerDisposed: Observable<Void>
}

struct GameTimerDisposalHandlingOutput {
    let stopMotionDetection: Observable<Void>
    let dismissWeaponChangeView: Observable<Void>
    let showResultView: Observable<Void>
}

protocol GameTimerDisposalHandlingUseCaseInterface {
    func transform(input: GameTimerDisposalHandlingInput) -> GameTimerDisposalHandlingOutput
}

final class GameTimerDisposalHandlingUseCase: GameTimerDisposalHandlingUseCaseInterface {
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(soundPlayer: SoundPlayerInterface = SoundPlayer.shared) {
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: GameTimerDisposalHandlingInput) -> GameTimerDisposalHandlingOutput {
        let resultViewShowingWaitTimeEnded = input.timerDisposed
            .flatMapLatest({ _ in
                return TimerStreamCreator
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
        
        return GameTimerDisposalHandlingOutput(
            stopMotionDetection: input.timerDisposed,
            dismissWeaponChangeView: input.timerDisposed,
            showResultView: resultViewShowingWaitTimeEnded
        )
    }
}
