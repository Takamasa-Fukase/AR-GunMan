//
//  UITapGestureRecognizer+Rx.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 14/6/24.
//

import RxSwift
import RxCocoa

final class UIGestureRecognizerDelegateProxy: DelegateProxy<UITapGestureRecognizer, UIGestureRecognizerDelegate> {

    fileprivate let nextTapEventInfoRelay = PublishRelay<(gestureRecognizer: UIGestureRecognizer, touch: UITouch)>()

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
        // この後にrecognizerにタップイベントとして流れる時に(recognizer, touch)の情報を使える様に保持
        nextTapEventInfoRelay.accept((gestureRecognizer, touch))
        return true
    }
}

extension Reactive where Base: UITapGestureRecognizer {
    private var delegateProxy: UIGestureRecognizerDelegateProxy {
        return UIGestureRecognizerDelegateProxy.proxy(for: base)
    }

    // タップ検知（touchUpInside）イベントに(recognizer, touch)の情報を一緒に付与して返却
    var tap: Observable<(gestureRecognizer: UIGestureRecognizer, touch: UITouch)> {
        return event
            .withLatestFrom(delegateProxy.nextTapEventInfoRelay)
    }
    
    // 最背面ビュー（recognizerがaddされているビュー）がタップされた時のイベント
    var backgroundViewTapped: Observable<Void> {
        return tap
            .filter({ $0.touch.view == $0.gestureRecognizer.view })
            .mapToVoid()
    }
}
