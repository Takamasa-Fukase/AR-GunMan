//
//  NotificationCenter+Extension.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/6/24.
//

import Foundation
import RxSwift
import RxCocoa

extension NotificationCenter {
    static var keyboardWillShow: Observable<Notification> {
        return self.default.rx.notification(UIResponder.keyboardWillShowNotification)
    }
    
    static var keyboardWillHide: Observable<Notification> {
        return self.default.rx.notification(UIResponder.keyboardWillHideNotification)
    }
}
