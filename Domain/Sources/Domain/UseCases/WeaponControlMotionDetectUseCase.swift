//
//  WeaponControlMotionDetectUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/22.
//

import Foundation

public protocol WeaponControlMotionDetectUseCaseInterface {
    var detectedMotionStream: AsyncStream<WeaponControlMotion> { get }
    func execute(acceleration: Vector?, gyro: Vector?)
}

public final class WeaponControlMotionDetectUseCase: WeaponControlMotionDetectUseCaseInterface {
    public let detectedMotionStream: AsyncStream<WeaponControlMotion>

    private var latestGyro: Vector?
    private let detectedMotionContinuation: AsyncStream<WeaponControlMotion>.Continuation

    public init() {
        (detectedMotionStream, detectedMotionContinuation) = AsyncStream.makeStream()
    }

    public func execute(acceleration: Vector?, gyro: Vector?) {
        if let motion = WeaponControlMotion.from(
            acceleration: acceleration,
            gyro: gyro ?? latestGyro
        ) {
            detectedMotionContinuation.yield(motion)
        }
        
        // ジャイロの値は発射モーションの判別にも使うので最新値を保持
        latestGyro = gyro
    }
}
