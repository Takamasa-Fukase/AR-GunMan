//
//  TutorialUseCase.swift
//  Sample_AR-GunMan_Replace
//
//  Created by ウルトラ深瀬 on 15/11/24.
//

import Foundation

public protocol TutorialUseCaseInterface {
    func checkCompletedFlag() -> Bool
    func updateCompletedFlag(isCompleted: Bool)
}

public final class TutorialUseCase {
    private let tutorialRepository: TutorialRepositoryInterface
    
    public init(tutorialRepository: TutorialRepositoryInterface) {
        self.tutorialRepository = tutorialRepository
    }
}

extension TutorialUseCase: TutorialUseCaseInterface {
    public func checkCompletedFlag() -> Bool {
        return tutorialRepository.getTutorialCompletedFlag()
    }
    
    public func updateCompletedFlag(isCompleted: Bool) {
        tutorialRepository.updateTutorialCompletedFlag(isCompleted: isCompleted)
    }
}
