//
//  ObservableActivityTracker.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/18.
//

import RxSwift
import RxCocoa

final class ObservableActivityTracker: ObservableConvertibleType {
    typealias Element = Bool
    
    private let isLoadingRelay = BehaviorRelay<Element>(value: false)
    
    fileprivate func trackActivity<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { [weak self] _ in
                self?.isLoadingRelay.accept(false)
            }, onError: { [weak self] _ in
                self?.isLoadingRelay.accept(false)
            }, onCompleted: {
                self.isLoadingRelay.accept(false)
            }, onSubscribe: {
                self.isLoadingRelay.accept(true)
            })
    }
    
    func asObservable() -> Observable<Element> {
        return isLoadingRelay.asObservable()
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ observableActivityTracker: ObservableActivityTracker) -> Observable<Element> {
        return observableActivityTracker.trackActivity(self)
    }
}
