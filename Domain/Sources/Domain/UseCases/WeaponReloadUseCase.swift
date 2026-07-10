//
//  WeaponReloadUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation
import Combine

public protocol WeaponReloadUseCaseInterface {
    func execute() -> WeaponReloadUseCase.Response
}

public final class WeaponReloadUseCase: WeaponReloadUseCaseInterface {
    public enum Progress {
        case started
        case ended(newBulletsCount: String)
    }
    public struct Response {
        public let progressEvent: AsyncStream<Progress>
        public let weaponType: WeaponType
    }
    
    private let weapon: Weapon

    public init(
        weapon: Weapon
    ) {
        self.weapon = weapon
    }
    
    public func execute() -> Response {
        let weaponType = weapon.currentType
        
        let progressEvent = AsyncStream<Progress> { continuation in
            weapon.isReloading = true
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
                self?.weapon.isReloading = false
                task.cancel()
            }
        }
        
        return Response(
            progressEvent: progressEvent,
            weaponType: weaponType
        )
    }
}
