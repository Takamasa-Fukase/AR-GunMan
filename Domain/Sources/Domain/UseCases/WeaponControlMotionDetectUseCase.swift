//
//  WeaponControlMotionDetectUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/22.
//

import Foundation

public protocol WeaponControlMotionDetectUseCaseInterface {
    func execute(motion: PhysicalMotion) -> WeaponControlMotion?
}

public final class WeaponControlMotionDetectUseCase: WeaponControlMotionDetectUseCaseInterface {

    private var latestGyro: PhysicalMotion?

    public init() {}

    public func execute(motion: PhysicalMotion) -> WeaponControlMotion? {
        switch motion.type {
        case .acceleration:
            return WeaponControlMotion.from(acceleration: motion, gyro: latestGyro)
            
        case .gyro:
            // ジャイロの値は発射モーションの判別にも使うので最新値を保持
            latestGyro = motion
            
            return WeaponControlMotion.from(gyro: motion)
        }
    }
}
