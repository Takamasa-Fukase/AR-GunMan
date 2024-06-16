//
//  ReloadingMotionDetectionCounter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 7/6/24.
//

import RxSwift
import RxCocoa

final class ReloadingMotionDetectionCounter: ViewModelEventHandlerType {
    struct Input {
        let reloadingMotionDetected: Observable<Void>
        let currentCount: Observable<Int>
    }
    
    struct Output {
        let updateCount: Observable<Int>
        let playTargetsAppearanceChangingSound: Observable<SoundType>
        let detectionCountReachedTargetsAppearanceChangingLimit: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let reloadingMotionDetected = input.reloadingMotionDetected
            .withLatestFrom(input.currentCount)
                
        let detectionCountReachedTargetsAppearanceChangingLimit = reloadingMotionDetected
            .filter({ $0 == GameConst.targetsAppearanceChangingLimit })
            .mapToVoid()

        return Output(
            updateCount: reloadingMotionDetected.map({ $0 + 1 }),
            playTargetsAppearanceChangingSound: detectionCountReachedTargetsAppearanceChangingLimit.map({ _ in .kyuiin }),
            detectionCountReachedTargetsAppearanceChangingLimit: detectionCountReachedTargetsAppearanceChangingLimit
        )
    }
}
