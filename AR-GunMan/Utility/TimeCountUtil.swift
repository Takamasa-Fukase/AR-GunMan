//
//  TimeCountUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/02.
//

import Foundation

class TimeCountUtil {
    func updateTimeCount(_ timeCount: Double) -> Double {
        let lowwerTime = 0.00
        return max(timeCount - 0.01, lowwerTime)
    }
    
    func twoDigitTimeCount(_ timeCount: Double) -> String {
        let strTimeCount = String(format: "%.2f", timeCount)
        return timeCount > 10 ? "\(strTimeCount)" : "0\(strTimeCount)"
    }
}
