//
//  ObservableErrorTracker.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 13/6/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ObservableErrorTracker: ObservableConvertibleType {
    private let errorRelay = PublishRelay<Error>()
    
    fileprivate func trackError<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onError: { [weak self] in
                self?.errorRelay.accept($0)
            })
    }
    
    func asObservable() -> Observable<Error> {
        return errorRelay.asObservable()
    }
}

extension ObservableConvertibleType {
    func trackError(_ observableErrorTracker: ObservableErrorTracker) -> Observable<Element> {
        return observableErrorTracker.trackError(self)
    }
}
