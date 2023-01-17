//
//  TimeCounter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 10/1/23.
//

import RxSwift
import RxCocoa

class TimeCounter {
//    private var isPlaying = false
    private var timerObservable: Disposable?
    let countChangedRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
    
    var countChanged: Observable<Double> {
        return countChangedRelay.asObservable()
    }
        
    init() {
//        let _countChanged = BehaviorRelay<Double>(value: GameConst.timeCount)
//        self.countChanged = _countChanged.asObservable()
        
//        timerObservable = TimeCountUtil.createRxTimer(.milliseconds(10))
//            .filter({ _ in self.isPlaying })
//            .map({_ in TimeCountUtil.decreaseGameTimeCount(lastValue: _countChanged.value)})
//            .bind(to: _countChanged)
    }
    
    func startTimer() {
//        isPlaying = true
        
        timerObservable = TimeCountUtil.createRxTimer(.milliseconds(10))
//            .filter({ _ in self.isPlaying })
            .map({_ in TimeCountUtil.decreaseGameTimeCount(lastValue: self.countChangedRelay.value)})
            .bind(to: countChangedRelay)
//            .subscribe(onNext: { element in
//                print("countChanged: \(element)")
//                self.countChangedRelay.accept(element)
//            })
    }
    
    func disposeTimer() {
        timerObservable?.dispose()
    }
}
