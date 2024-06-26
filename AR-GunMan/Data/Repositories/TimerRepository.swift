//
//  TimerRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/07.
//

import RxSwift

// TODO: - 差し替えが終わったらこのファイルを削除する
protocol TimerRepositoryInterface {
    func getTimerStream(milliSec: Int, isRepeated: Bool) -> Observable<Int>
}

final class TimerRepository: TimerRepositoryInterface {
    func getTimerStream(milliSec: Int, isRepeated: Bool) -> Observable<Int> {
        // 返却されるInt値は、タイマーが更新された回数。1ずつ加算された値がStreamで返却される。
        return Observable<Int>
            .timer(
                .milliseconds(milliSec),
                period: isRepeated ? .milliseconds(milliSec) : nil,
                scheduler: MainScheduler.instance
            )
    }
}
