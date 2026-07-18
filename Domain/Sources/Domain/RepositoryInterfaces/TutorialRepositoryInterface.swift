//
//  TutorialRepositoryInterface.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 11/11/24.
//

import Foundation
import Combine

public protocol TutorialRepositoryInterface {
    var isTutorialCompletedPublisher: AnyPublisher<Bool, Never> { get }
    func getTutorialCompletedFlag() -> Bool
    func updateTutorialCompletedFlag(isCompleted: Bool)
}
