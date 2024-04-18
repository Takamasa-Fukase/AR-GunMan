//
//  ObservableActivityTracker.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/18.
//

import RxSwift
import RxCocoa

class ObservableActivityTracker: ObservableConvertibleType {
    typealias Element = Bool
    
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    fileprivate func trackActivity<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(false)
            }, onError: { [weak self] _ in
                self?.isLoading.accept(false)
            }, onCompleted: {
                self.isLoading.accept(false)
            }, onSubscribe: {
                self.isLoading.accept(true)
            })
    }
    
    func asObservable() -> Observable<Element> {
        return isLoading.asObservable()
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ observableActivityTracker: ObservableActivityTracker) -> Observable<Element> {
        return observableActivityTracker.trackActivity(self)
    }
}
