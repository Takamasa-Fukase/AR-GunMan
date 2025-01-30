//
//  TutorialRepositoryInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 11/11/24.
//

import Foundation

public protocol TutorialRepositoryInterface {
    func getTutorialCompletedFlag() -> Bool
    func updateTutorialCompletedFlag(isCompleted: Bool)
}
