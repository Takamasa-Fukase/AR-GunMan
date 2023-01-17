//
//  TutorialSeenChecker.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/1/23.
//

import RxSwift
import RxCocoa

class TutorialSeenChecker {
    var isSeen: Observable<Bool> {
        return isSeenRelay.asObservable()
    }

    private let isSeenRelay = PublishRelay<Bool>()

    func checkTutorialSeen() {
        isSeenRelay.accept(UserDefaults.isTutorialAlreadySeen)
    }
}

extension TutorialSeenChecker: TutorialVCDelegate {
    func tutorialEnded() {
        isSeenRelay.accept(true)
    }
}
