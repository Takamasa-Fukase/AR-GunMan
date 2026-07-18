//
//  TutorialRepository.swift
//  Data
//
//  Created by ウルトラ深瀬 on 11/11/24.
//

import Foundation
import Domain

public final class TutorialRepository: TutorialRepositoryInterface {
    private var userDefaultsDataSource: UserDefaultsDataSourceInterface
    
    public init(userDefaultsDataSource: UserDefaultsDataSourceInterface) {
        self.userDefaultsDataSource = userDefaultsDataSource
    }
    
    public func getTutorialCompletedFlag() -> Bool {
        return userDefaultsDataSource.isTutorialCompleted
    }
    
    public func updateTutorialCompletedFlag(isCompleted: Bool) {
        userDefaultsDataSource.isTutorialCompleted = isCompleted
    }
}
