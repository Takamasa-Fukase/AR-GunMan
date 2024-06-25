//
//  UIView+UIViewController+BackgroundViewTapTrackable.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 15/6/24.
//

import UIKit
import RxSwift

protocol BackgroundViewTapTrackable {
    func trackBackgroundViewTap() -> Observable<Void>
}

extension BackgroundViewTapTrackable where Self: UIView {
    func trackBackgroundViewTap() -> Observable<Void> {
        let backgroundViewTapRecognizer = UITapGestureRecognizer()
        // MEMO: XibをFilesOwnerでロードしている関係で一枚間にViewが挟まっている
        let firstView = subviews.first
        firstView?.addGestureRecognizer(backgroundViewTapRecognizer)
        return backgroundViewTapRecognizer.rx.backgroundViewTapped
    }
}

extension BackgroundViewTapTrackable where Self: UIViewController {
    func trackBackgroundViewTap() -> Observable<Void> {
        let backgroundViewTapRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(backgroundViewTapRecognizer)
        return backgroundViewTapRecognizer.rx.backgroundViewTapped
    }
}
