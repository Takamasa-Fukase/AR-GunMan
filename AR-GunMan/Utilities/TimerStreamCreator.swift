//
//  TimerStreamCreator.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift

final class TimerStreamCreator {
    private let scheduler: SchedulerType
    
    init(scheduler: SchedulerType = MainScheduler.instance) {
        self.scheduler = scheduler
    }
    
    func create(milliSec: Int, isRepeated: Bool) -> Observable<Int> {
        // 返却されるInt値は、タイマーが更新された回数。1ずつ加算された値がStreamで返却される。
        return Observable<Int>
            .timer(
                .milliseconds(milliSec),
                period: isRepeated ? .milliseconds(milliSec) : nil,
                scheduler: scheduler
            )
    }
}
