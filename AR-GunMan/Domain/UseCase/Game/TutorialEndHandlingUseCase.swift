//
//  TutorialEndHandlingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 20/6/24.
//

import RxSwift
import RxCocoa

struct TutorialEndHandlingInput {
    let tutorialEnded: Observable<Void>
}

struct TutorialEndHandlingOutput {
    let startGame: Observable<Void>
}

protocol TutorialEndHandlingUseCaseInterface {
    func transform(input: TutorialEndHandlingInput) -> TutorialEndHandlingOutput
}

final class TutorialEndHandlingUseCase: TutorialEndHandlingUseCaseInterface {
    private let tutorialRepository: TutorialRepositoryInterface

    init(tutorialRepository: TutorialRepositoryInterface) {
        self.tutorialRepository = tutorialRepository
    }
    
    func transform(input: TutorialEndHandlingInput) -> TutorialEndHandlingOutput {
        let startGame = input.tutorialEnded
            .flatMapLatest({  [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.tutorialRepository.setTutorialAlreadySeen()
            })
        
        return TutorialEndHandlingOutput(
            startGame: startGame
        )
    }
}
