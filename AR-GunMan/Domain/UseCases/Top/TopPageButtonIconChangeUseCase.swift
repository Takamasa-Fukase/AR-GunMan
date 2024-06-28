//
//  TopPageButtonIconChangeUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct TopPageButtonIconChangeInput {
    let buttonTapped: Observable<Void>
}

struct TopPageButtonIconChangeOutput {
    let isButtonIconSwitched: Observable<Bool>
    let buttonIconReverted: Observable<Void>
}

protocol TopPageButtonIconChangeUseCaseInterface {
    func transform(input: TopPageButtonIconChangeInput) -> TopPageButtonIconChangeOutput
}

final class TopPageButtonIconChangeUseCase: TopPageButtonIconChangeUseCaseInterface {
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
    
    func transform(input: TopPageButtonIconChangeInput) -> TopPageButtonIconChangeOutput {
        let isButtonIconSwitchedRelay = PublishRelay<Bool>()

        let iconRevertWaitTimeEnded = input.buttonTapped
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.timerStreamCreator
                    .create(
                        milliSec: TopConst.iconRevertWaitingTimeMillisec,
                        isRepeated: false
                    )
                    .mapToVoid()
            })
        
        disposeBag.insert {
            input.buttonTapped
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    isButtonIconSwitchedRelay.accept(true)
                    self.soundPlayer.play(TopConst.iconChangingSound)
                })
            iconRevertWaitTimeEnded
                .subscribe(onNext: { _ in
                    isButtonIconSwitchedRelay.accept(false)
                })
        }
        
        return TopPageButtonIconChangeOutput(
            isButtonIconSwitched: isButtonIconSwitchedRelay.asObservable(),
            buttonIconReverted: iconRevertWaitTimeEnded
        )
    }
}
