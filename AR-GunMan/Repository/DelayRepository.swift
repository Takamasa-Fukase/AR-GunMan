//
//  DelayRepository.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/07.
//

import RxSwift

protocol DelayRepositoryInterface {
    func awaitGameStartSignal() -> Observable<Void>
    func awaitShowResultSignal() -> Observable<Void>
}

final class DelayRepository: DelayRepositoryInterface {
    func awaitGameStartSignal() -> Observable<Void> {
        return Observable<Int>
            .timer(.milliseconds(1500), scheduler: MainScheduler.instance)
            .map({ _ in })
    }
    
    func awaitShowResultSignal() -> Observable<Void> {
        return Observable<Int>
            .timer(.milliseconds(1500), scheduler: MainScheduler.instance)
            .map({ _ in })
    }
}
