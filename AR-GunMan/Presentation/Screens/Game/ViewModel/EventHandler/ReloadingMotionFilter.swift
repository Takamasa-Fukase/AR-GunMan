//
//  ReloadingMotionFilter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/5/24.
//

import RxSwift
import RxCocoa

final class ReloadingMotionFilter: ViewModelEventHandlerType {
    struct Input {
        let gyroUpdated: Observable<(x: Double, y: Double, z: Double)>
    }
    
    struct Output {
        let reloadingMotionDetected: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let reloadingMotionDetected = input.gyroUpdated
            .map{ gyro in
                return CompositeCalculator.getCompositeValue(x: 0, y: 0, z: gyro.z)
            }
            .filter { gyroCompositeValue in
                gyroCompositeValue >= 10
            }
            .map({_ in})
        return Output(reloadingMotionDetected: reloadingMotionDetected)
    }
}
