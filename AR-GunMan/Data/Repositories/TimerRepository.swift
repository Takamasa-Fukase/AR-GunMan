//
//  TimerRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/07.
//

import RxSwift

protocol TimerRepositoryInterface {
    func getTimerStream(milliSec: Int, isRepeatd: Bool) -> Observable<Int>
}

final class TimerRepository: TimerRepositoryInterface {
    func getTimerStream(milliSec: Int, isRepeatd: Bool) -> Observable<Int> {
        // 返却されるInt値は、タイマーが更新された回数。1ずつ加算された値がStreamで返却される。
        return Observable<Int>
            .timer(
                .milliseconds(milliSec),
                period: isRepeatd ? .milliseconds(milliSec) : nil,
                scheduler: MainScheduler.instance
            )
    }
}
