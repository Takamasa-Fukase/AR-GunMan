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
    let playIconChangingSound: Observable<SoundType>
    let buttonIconReverted: Observable<Void>
}

protocol TopPageButtonIconChangeUseCaseInterface {
    func transform(input: TopPageButtonIconChangeInput) -> TopPageButtonIconChangeOutput
}

final class TopPageButtonIconChangeUseCase: TopPageButtonIconChangeUseCaseInterface {
    func transform(input: TopPageButtonIconChangeInput) -> TopPageButtonIconChangeOutput {
        let isButtonIconSwitchedRelay = PublishRelay<Bool>()
        
        let playIconChangingSound = input.buttonTapped
            .map({ _ in
                return TopConst.iconChangingSound
            })
        
        let buttonIconReverted = input.buttonTapped
            .do(onNext: { _ in
                isButtonIconSwitchedRelay.accept(true)
            })
            .flatMapLatest({ _ in
                return TimerStreamCreator
                    .create(
                        milliSec: TopConst.iconRevertWaitingTimeMillisec,
                        isRepeated: false
                    )
                    .mapToVoid()
            })
            .do(onNext: { _ in
                isButtonIconSwitchedRelay.accept(false)
            })
        
        return TopPageButtonIconChangeOutput(
            isButtonIconSwitched: isButtonIconSwitchedRelay.asObservable(),
            playIconChangingSound: playIconChangingSound,
            buttonIconReverted: buttonIconReverted
        )
    }
}
