//
//  TimeCounter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 10/1/23.
//

import RxSwift
import RxCocoa

class TimeCounter {
    var countChanged: Observable<Double> {
        return countChangedRelay.asObservable()
    }
    let countEnded: Observable<Void>

    private let countChangedRelay = BehaviorRelay<Double>(value: GameConst.timeCount)
    private var timerObservable: Disposable?
    private let disposeBag = DisposeBag()
    
    init() {
        let countEndedRelay = PublishRelay<Void>()
        self.countEnded = countEndedRelay.asObservable()

        countChanged
            .filter({$0 <= 0})
            .subscribe(onNext: { _ in
                countEndedRelay.accept(Void())
            }).disposed(by: disposeBag)
    }

    func startTimer() {
        timerObservable = TimeCountUtil.createRxTimer(.milliseconds(10))
            .map({_ in TimeCountUtil.decreaseGameTimeCount(lastValue: self.countChangedRelay.value)})
            .bind(to: countChangedRelay)
    }
    
    func disposeTimer() {
        timerObservable?.dispose()
    }
}
