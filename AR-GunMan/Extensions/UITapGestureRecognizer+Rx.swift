//
//  UITapGestureRecognizer+Rx.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 14/6/24.
//

import RxSwift
import RxCocoa

final class UIGestureRecognizerDelegateProxy: DelegateProxy<UITapGestureRecognizer, UIGestureRecognizerDelegate> {

    fileprivate let shouldReceiveCalledRelay = PublishRelay<(gestureRecognizer: UIGestureRecognizer, touch: UITouch)>()

    init(parentObject: ParentObject) {
        super.init(parentObject: parentObject, delegateProxy: UIGestureRecognizerDelegateProxy.self)
    }
}

extension UIGestureRecognizerDelegateProxy: DelegateProxyType {
    public static func registerKnownImplementations() {
        self.register { UIGestureRecognizerDelegateProxy(parentObject: $0) }
    }

    static func currentDelegate(for object: UITapGestureRecognizer) -> (any UIGestureRecognizerDelegate)? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: (any UIGestureRecognizerDelegate)?, to object: UITapGestureRecognizer) {
        object.delegate = delegate
    }
}

extension UIGestureRecognizerDelegateProxy: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        shouldReceiveCalledRelay.accept((gestureRecognizer, touch))
        return true
    }
}

extension Reactive where Base: UITapGestureRecognizer {
    private var delegateProxy: UIGestureRecognizerDelegateProxy {
        return UIGestureRecognizerDelegateProxy.proxy(for: base)
    }

    var shouldReceiveCalled: Observable<(gestureRecognizer: UIGestureRecognizer, touch: UITouch)> {
        return delegateProxy.shouldReceiveCalledRelay.asObservable()
    }
}
