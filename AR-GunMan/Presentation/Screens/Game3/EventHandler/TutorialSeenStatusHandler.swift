//
//  TutorialSeenStatusHandler.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 1/6/24.
//

import RxSwift
import RxCocoa

final class TutorialSeenStatusHandler {
    struct Input {
        let checkTutorialSeenStatus: Observable<Void>
    }
    
    struct Output {
        let startGame: Observable<Void>
        let showTutorial: Observable<Void>
    }
    
    private let gameUseCase: GameUseCase2Interface
    
    init(gameUseCase: GameUseCase2Interface) {
        self.gameUseCase = gameUseCase
    }
    
    func transform(input: Input) -> Output {
        let isTutorialSeen = input.checkTutorialSeenStatus
            .flatMapLatest({  [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.gameUseCase.getIsTutorialSeen()
            })
            .share()
        
        let startGame = isTutorialSeen
            .filter({ $0 })
            .map({ _ in })
        
        let showTutorial = isTutorialSeen
            .filter({ !$0 })
            .map({ _ in })
        
        return Output(
            startGame: startGame,
            showTutorial: showTutorial
        )
    }
}
