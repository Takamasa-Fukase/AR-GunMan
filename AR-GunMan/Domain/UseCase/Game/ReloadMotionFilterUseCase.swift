//
//  ReloadMotionFilterUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct ReloadMotionFilterInput {
    let gyroUpdated: Observable<Vector>
}

struct ReloadMotionFilterOutput {
    let reloadMotionDetected: Observable<Void>
}

protocol ReloadMotionFilterUseCaseInterface {
    func transform(input: ReloadMotionFilterInput) -> ReloadMotionFilterOutput
}

final class ReloadMotionFilterUseCase: ReloadMotionFilterUseCaseInterface {
    func transform(input: ReloadMotionFilterInput) -> ReloadMotionFilterOutput {
        let reloadMotionDetected = input.gyroUpdated
            .map{ gyro in
                return CompositeCalculator.getCompositeValue(x: 0, y: 0, z: gyro.z)
            }
            .filter { gyroCompositeValue in
                gyroCompositeValue >= 10
            }
            .mapToVoid()
        
        return ReloadMotionFilterOutput(
            reloadMotionDetected: reloadMotionDetected
        )
    }
}
