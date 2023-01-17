//
//  TutorialSeenChecker.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/1/23.
//

import RxSwift
import RxCocoa

class TutorialSeenChecker {
    private let isSeenRelay = PublishRelay<Bool>()

    var isSeen: Observable<Bool> {
        return isSeenRelay.asObservable()
    }
    
    func checkTutorialSeen() {
        isSeenRelay.accept(UserDefaults.isTutorialAlreadySeen)
    }
}

extension TutorialSeenChecker: TutorialVCDelegate {
    func tutorialEnded() {
        isSeenRelay.accept(true)
    }
}
