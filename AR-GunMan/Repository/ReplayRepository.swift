//
//  ReplayRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/15.
//

import RxSwift

protocol ReplayRepositoryInterface {
    func getNeedsReplay() -> Observable<Bool>
    func setNeedsReplay(_ newValue: Bool)
}

final class ReplayRepository: ReplayRepositoryInterface {
    func getNeedsReplay() -> Observable<Bool> {
        return Observable.just(UserDefaults.needsReplay)
    }
    
    func setNeedsReplay(_ newValue: Bool) {
        UserDefaults.needsReplay = newValue
    }
}
