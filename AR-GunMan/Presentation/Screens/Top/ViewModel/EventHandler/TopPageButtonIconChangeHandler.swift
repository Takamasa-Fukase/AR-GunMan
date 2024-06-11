//
//  TopPageButtonIconChangeHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/6/24.
//

import RxSwift
import RxCocoa

final class TopPageButtonIconChangeHandler: ViewModelEventHandlerType {
    struct Input {
        let buttonTapped: Observable<Void>
    }
    
    struct Output {
        let isButtonIconSwitched: Observable<Bool>
        let playIconChangingSound: Observable<SoundType>
        let buttonIconReverted: Observable<Void>
    }
    
    private let topUseCase: TopUseCaseInterface2
    private let soundPlayer: SoundPlayerInterface
    
    init(
        topUseCase: TopUseCaseInterface2,
        soundPlayer: SoundPlayerInterface
    ) {
        self.topUseCase = topUseCase
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: Input) -> Output {
        let isButtonIconSwitchedRelay = PublishRelay<Bool>()
        
        let playIconChangingSound = input.buttonTapped
            .map({ _ in TopConst.iconChangingSound })
        
        let buttonIconReverted = input.buttonTapped
            .do(onNext: { _ in
                isButtonIconSwitchedRelay.accept(true)
            })
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return topUseCase.awaitIconRevertSignal()
            })
            .do(onNext: { _ in
                isButtonIconSwitchedRelay.accept(false)
            })
        
        return Output(
            isButtonIconSwitched: isButtonIconSwitchedRelay.asObservable(),
            playIconChangingSound: playIconChangingSound,
            buttonIconReverted: buttonIconReverted
        )
    }
}
