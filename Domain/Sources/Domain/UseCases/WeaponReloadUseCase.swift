//
//  WeaponReloadUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation
import Combine

public protocol WeaponReloadUseCaseInterface {
    func execute()
}

public final class WeaponReloadUseCase: WeaponReloadUseCaseInterface {
    public struct State {
        public let bulletsCount: Int
    }
    public struct Event {
        public let weaponType: WeaponType
        public let progress: WeaponReloadProgress
    }
    
    public var state: State {
        return State(bulletsCount: weaponRepository.weapon.bulletsCount)
    }
    
    public let event = AsyncStream<Event> { continuation in
        eventContinuation = continuation
    }
    
    private let weaponRepository: WeaponRepositoryInterface
    private let eventContinuation: AsyncStream<Event>.Continuation?

    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
    }
    
    public func execute() {
        let weaponType = weaponRepository.weapon.currentType
        
        let progressEvent = AsyncStream<Progress> { continuation in
            weaponRepository.weapon.startReload()
            continuation.yield(.started)
            
            let task = Task {
                do {
                    try await Task.sleep(for: .milliseconds(weaponType.weaponInfo.spec.reloadWaitingTimeMillisec))
                    continuation.yield(.ended)
                    continuation.finish()
                    
                } catch {
                    print("リロード待ち時間の遅延処理がキャンセルされました")
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { @Sendable [weak self] _ in
                self?.weaponRepository.weapon.finishReload()
                task.cancel()
            }
        }
        
        return Response(
            progressEvent: progressEvent,
            weaponType: weaponType
        )
    }
}
