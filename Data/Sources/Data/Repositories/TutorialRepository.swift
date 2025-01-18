//
//  TutorialRepository.swift
//  Sample_AR-GunMan_Replace
//
//  Created by ウルトラ深瀬 on 11/11/24.
//

import Foundation
import DomainLayer

public final class TutorialRepository: TutorialRepositoryInterface {
    public init() {}
    
    public func getTutorialCompletedFlag() -> Bool {
        return UserDefaults.isTutorialCompleted
    }
    
    public func updateTutorialCompletedFlag(isCompleted: Bool) {
        UserDefaults.isTutorialCompleted = isCompleted
    }
}
