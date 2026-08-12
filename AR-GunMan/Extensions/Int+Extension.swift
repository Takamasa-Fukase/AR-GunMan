//
//  Int+Extension.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/07/19.
//

import Foundation

extension Int {
    var timeCountText: String {
        // Int型のミリ秒: 30秒 なら 30000
        let timeCountMillisec: Int = self
        
        // Double型の秒: 30秒 なら 30.00
        let doubleTimeCount = Double(timeCountMillisec) / Double(1000)
        
        // String型の秒: 30秒 なら "30.00"
        let strTimeCount = String(format: "%.2f", doubleTimeCount)

        // 1桁秒の場合は0埋め
        if timeCountMillisec < 10000 {
            return "0\(strTimeCount)"
        } else {
            return "\(strTimeCount)"
        }
    }
}
