//
//  NSObject+Extension.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 10/6/24.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
