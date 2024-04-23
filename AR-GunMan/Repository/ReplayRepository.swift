//
//  ReplayRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/15.
//

import RxSwift

final class ReplayRepository {
    func getNeedsReplay() -> Observable<Bool> {
        return Observable.just(UserDefaults.needsReplay)
    }
    
    func setNeedsReplay(_ newValue: Bool) {
        UserDefaults.needsReplay = newValue
    }
}
