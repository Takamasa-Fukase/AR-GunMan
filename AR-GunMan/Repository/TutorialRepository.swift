//
//  TutorialRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/03/24.
//

import RxSwift

class TutorialRepository {
    func getIsTutorialSeen() -> Observable<Bool> {
        return Observable.just(UserDefaults.isTutorialAlreadySeen)
    }
    
    func setTutorialAlreadySeen() {
        UserDefaults.isTutorialAlreadySeen = true
    }
}
