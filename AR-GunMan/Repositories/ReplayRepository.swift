//
//  ReplayRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/15.
//

import RxSwift

protocol ReplayRepositoryInterface {
    func getNeedsReplay() -> Observable<Bool>
    func setNeedsReplay(_ newValue: Bool) -> Observable<Void>
}

final class ReplayRepository: ReplayRepositoryInterface {
    func getNeedsReplay() -> Observable<Bool> {
        return Observable.just(UserDefaults.needsReplay)
    }
    
    func setNeedsReplay(_ newValue: Bool) -> Observable<Void> {
        UserDefaults.needsReplay = newValue
        return Observable.just(Void())
    }
}
