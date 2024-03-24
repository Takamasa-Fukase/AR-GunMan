//
//  TutorialSeenChecker2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/1/23.
//

import RxSwift
import RxCocoa

class TutorialSeenChecker2 {
    private let isSeenRelay = BehaviorRelay<Bool>(value: UserDefaults.isTutorialAlreadySeen)

    func checkTutorialSeen() -> Observable<Bool> {
        return isSeenRelay.asObservable()
    }
}

extension TutorialSeenChecker2: TutorialDelegate {
    func tutorialEnded() {
        isSeenRelay.accept(true)
    }
}
