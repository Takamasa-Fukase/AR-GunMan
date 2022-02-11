//
//  TimeCountUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/02.
//

import Foundation
import RxSwift

class TimeCountUtil {
    
    //Rxタイマーを生成
    static func createRxTimer(_ interval: RxTimeInterval) -> Observable<Int> {
        return Observable<Int>.interval(interval, scheduler: MainScheduler.instance)
    }
    
    //30.00から経過時間を引いた値に変換
    static func decreaseGameTimeCount(elapsedTime: Double) -> Double {
        return max(Const.timeCount - elapsedTime, 0.00)
    }
    
    //2桁のStringに変換（1桁の場合は0埋めする）
    static func twoDigitTimeCount(_ timeCount: Double) -> String {
        let strTimeCount = String(format: "%.2f", timeCount)
        return timeCount > 10 ? "\(strTimeCount)" : "0\(strTimeCount)"
    }
}
