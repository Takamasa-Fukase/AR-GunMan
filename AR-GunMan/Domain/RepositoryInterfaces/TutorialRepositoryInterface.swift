//
//  TutorialRepositoryInterface.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/6/24.
//

import RxSwift

protocol TutorialRepositoryInterface {
    func getIsTutorialSeen() -> Observable<Bool>
    func setTutorialAlreadySeen() -> Observable<Void>
}
