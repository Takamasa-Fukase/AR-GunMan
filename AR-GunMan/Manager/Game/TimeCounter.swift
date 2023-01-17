//
//  TimeCounter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 10/1/23.
//

import RxSwift
import RxCocoa

class TimeCounter {
    let countChangedRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
    var countChanged: Observable<Double> {
        return countChangedRelay.asObservable()
    }
    
    private var timerObservable: Disposable?

    func startTimer() {
        timerObservable = TimeCountUtil.createRxTimer(.milliseconds(10))
            .map({_ in TimeCountUtil.decreaseGameTimeCount(lastValue: self.countChangedRelay.value)})
            .bind(to: countChangedRelay)
    }
    
    func disposeTimer() {
        timerObservable?.dispose()
    }
}
