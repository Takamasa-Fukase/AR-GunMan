//
//  FireMotionFilterUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct FireMotionFilterInput {
    let accelerationUpdated: Observable<Vector>
    let gyroUpdated: Observable<Vector>
}

struct FireMotionFilterOutput {
    let fireMotionDetected: Observable<Void>
}

protocol FireMotionFilterUseCaseInterface {
    func transform(input: FireMotionFilterInput) -> FireMotionFilterOutput
}

final class FireMotionFilterUseCase: FireMotionFilterUseCaseInterface {
    func transform(input: FireMotionFilterInput) -> FireMotionFilterOutput {
        let fireMotionDetected = input.accelerationUpdated
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
            .mapToVoid()
        
        return FireMotionFilterOutput(
            fireMotionDetected: fireMotionDetected
        )
    }
}
