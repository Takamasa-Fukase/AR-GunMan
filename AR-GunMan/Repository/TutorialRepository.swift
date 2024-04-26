//
//  TutorialRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/03/24.
//

import RxSwift

protocol TutorialRepositoryInterface {
    func getIsTutorialSeen() -> Observable<Bool>
    func setTutorialAlreadySeen()
}

final class TutorialRepository: TutorialRepositoryInterface {
    func getIsTutorialSeen() -> Observable<Bool> {
        return Observable.just(UserDefaults.isTutorialAlreadySeen)
    }
    
    func setTutorialAlreadySeen() {
        UserDefaults.isTutorialAlreadySeen = true
    }
}
