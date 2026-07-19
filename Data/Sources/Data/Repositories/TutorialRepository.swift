//
//  TutorialRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 11/11/24.
//

import Foundation
import Domain

public final class TutorialRepository: TutorialRepositoryInterface {
    private var userDefaultsClient: UserDefaultsClientInterface
    
    public init(userDefaultsClient: UserDefaultsClientInterface) {
        self.userDefaultsClient = userDefaultsClient
    }
    
    public func getTutorialCompletedFlag() -> Bool {
        return userDefaultsClient.isTutorialCompleted
    }
    
    public func updateTutorialCompletedFlag(isCompleted: Bool) {
        userDefaultsClient.isTutorialCompleted = isCompleted
    }
}
