//
//  TimeCountUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/02.
//

import Foundation
import RxSwift

final class TimeCountUtil {
    //2桁のStringに変換（1桁の場合は0埋めする）
    static func twoDigitTimeCount(_ timeCount: Double) -> String {
        let strTimeCount = String(format: "%.2f", timeCount)
        return timeCount > 10 ? "\(strTimeCount)" : "0\(strTimeCount)"
    }
}
