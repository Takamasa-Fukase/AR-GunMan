//
//  WeaponControlMotionDetectUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/22.
//

import Foundation

public protocol WeaponControlMotionDetectUseCaseInterface {
    var detectedMotionStream: AsyncStream<WeaponControlMotion> { get }
    func execute(motion: PhysicalMotion)
}

public final class WeaponControlMotionDetectUseCase: WeaponControlMotionDetectUseCaseInterface {
    public let detectedMotionStream: AsyncStream<WeaponControlMotion>

    private var latestGyro: PhysicalMotion?
    private let detectedMotionContinuation: AsyncStream<WeaponControlMotion>.Continuation

    public init() {
        (detectedMotionStream, detectedMotionContinuation) = AsyncStream.makeStream()
    }

    public func execute(motion: PhysicalMotion) {
        switch motion.type {
        case .acceleration:
            guard let firingMotion = WeaponControlMotion.from(acceleration: motion, gyro: latestGyro) else {
                return
            }
            detectedMotionContinuation.yield(firingMotion)
            
        case .gyro:
            // ジャイロの値は発射モーションの判別にも使うので最新値を保持
            latestGyro = motion
            guard let reloadingMotion = WeaponControlMotion.from(gyro: motion) else {
                return
            }
            detectedMotionContinuation.yield(reloadingMotion)
        }
    }
}
