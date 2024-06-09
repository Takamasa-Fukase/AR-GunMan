//
//  FiringMotionFilter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/5/24.
//

import RxSwift
import RxCocoa

final class FiringMotionFilter: ViewModelEventHandlerType {
    struct Input {
        let accelerationUpdated: Observable<(x: Double, y: Double, z: Double)>
        let gyroUpdated: Observable<(x: Double, y: Double, z: Double)>
    }
    
    struct Output {
        let firingMotionDetected: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let firingMotionDetected = input.accelerationUpdated
            .withLatestFrom(input.gyroUpdated) { ($0, $1) }
            .map{ (acceleration, gyro) in
                return (
                    CompositeCalculator.getCompositeValue(x: 0, y: acceleration.y, z: acceleration.z),
                    CompositeCalculator.getCompositeValue(x: 0, y: 0, z: gyro.z)
                )
            }
            .filter { (accelerationCompositeValue, gyroCompositeValue) in
                return accelerationCompositeValue >= 1.5 && gyroCompositeValue < 10
            }
            .map({ _ in })
        return Output(firingMotionDetected: firingMotionDetected)
    }
}
