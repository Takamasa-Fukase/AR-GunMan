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
        case ended
    }
    public struct Response {
        public let progressEvent: AsyncStream<Progress>
        public let weaponType: WeaponType
    }
    
    private let weaponSession: WeaponSession

    public init(
        weaponSession: WeaponSession,
    ) {
        self.weaponSession = weaponSession
    }
    
    public func execute() -> Response {
        let weaponType = weaponSession.currentWeaponType
        
        let progressEvent = AsyncStream<Progress> { continuation in
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
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
        
        return Response(
            progressEvent: progressEvent,
            weaponType: weaponType
        )
    }
}
