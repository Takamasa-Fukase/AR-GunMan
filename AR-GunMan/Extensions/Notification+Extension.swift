//
//  Notification+Extension.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 16/6/24.
//

import UIKit

extension Notification {
    var keyboardAnimationDuration: TimeInterval? {
        return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
    }
    
    var keyboardFrameEnd: CGRect? {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }
}
