//
//  TutorialNecessityCheckUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct TutorialNecessityCheckInput {
    let trigger: Observable<Void>
}

struct TutorialNecessityCheckOutput {
    let showTutorial: Observable<Void>
    let startGame: Observable<Void>
}

protocol TutorialNecessityCheckUseCaseInterface {
    func transform(input: TutorialNecessityCheckInput) -> TutorialNecessityCheckOutput
}

final class TutorialNecessityCheckUseCase: TutorialNecessityCheckUseCaseInterface {
    private let tutorialRepository: TutorialRepositoryInterface

    init(tutorialRepository: TutorialRepositoryInterface) {
        self.tutorialRepository = tutorialRepository
    }
    
    func transform(input: TutorialNecessityCheckInput) -> TutorialNecessityCheckOutput {
        let isTutorialAlreadySeen = input.trigger
            .flatMapLatest({  [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.tutorialRepository.getIsTutorialSeen()
            })
            .share()
        
        let showTutorial = isTutorialAlreadySeen
            .filter({ !$0 })
            .mapToVoid()
        
        let startGame = isTutorialAlreadySeen
            .filter({ $0 })
            .mapToVoid()
        
        return TutorialNecessityCheckOutput(
            showTutorial: showTutorial,
            startGame: startGame
        )
    }
}
