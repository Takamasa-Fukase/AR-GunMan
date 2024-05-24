//
//  DeviceMotionEventTransformer.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/23.
//

import RxSwift
import RxCocoa

final class DeviceMotionEventTransformer: ViewModelType {
    struct Input {
        let timeCountStarted: Observable<Void>
        let timeCountEnded: Observable<Void>
        let accelerationUpdated: Observable<(x: Double, y: Double, z: Double)>
        let gyroUpdated: Observable<(x: Double, y: Double, z: Double)>
    }
    
    struct Output {
        let startMotionDetection: Observable<Void>
        let stopMotionDetection: Observable<Void>
        let firingMotionDetected: Observable<Void>
        let reloadingMotionDetected: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let startMotionDetection = input.timeCountStarted
        
        let stopMotionDetection = input.timeCountEnded
        
        let firingMotionDetected = CoreMotionStreamFilter
            .filterFiringMotionStream(
                accelerationStream: input.accelerationUpdated,
                gyroStream: input.gyroUpdated
            )
        
        let reloadingMotionDetected = CoreMotionStreamFilter
            .filterReloadingMotionStream(
                gyroStream: input.gyroUpdated
            )
//            .map({ _ in
//                // リロードモーションの検知回数をインクリメントする
//                state.reloadingMotionDetectedCountRelay.accept(
//                    state.reloadingMotionDetectedCountRelay.value + 1
//                )
//            })
        
        return Output(
            startMotionDetection: startMotionDetection,
            stopMotionDetection: stopMotionDetection,
            firingMotionDetected: firingMotionDetected,
            reloadingMotionDetected: reloadingMotionDetected
        )
    }
}



