//
//  WeaponReloadUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

@MainActor
public protocol WeaponReloadUseCaseInterface {
    var reloadStartResultEvent: AsyncStream<WeaponReloadStartResult> { get }
    func execute()
    func stopCurrentReloadIfExists()
}


@MainActor
public final class WeaponReloadUseCase: WeaponReloadUseCaseInterface {
    public let reloadStartResultEvent: AsyncStream<WeaponReloadStartResult>

    private var weaponStore: WeaponStoreInterface
    private var reloadTask: Task<Void, Never>?
    private let reloadStartResultEventContinuation: AsyncStream<WeaponReloadStartResult>.Continuation

    public init(weaponStore: WeaponStoreInterface) {
        self.weaponStore = weaponStore
        
        (reloadStartResultEvent, reloadStartResultEventContinuation) = AsyncStream.makeStream()
    }
    
    public func execute() {
        let startResult = weaponStore.weapon.startReload()
        reloadStartResultEventContinuation.yield(startResult)

        reloadTask = Task {
            try? await Task.sleep(
                for: .milliseconds(
                    weaponStore.weapon.currentType.reloadWaitingTimeMillisec
                )
            )
            
            // reloadTaskがキャンセルされている場合はfinishReloadさせない
            guard !Task.isCancelled else { return }
            
            weaponStore.weapon.finishReload()
        }
    }
    
    public func stopCurrentReloadIfExists() {
        reloadTask?.cancel()
        reloadTask = nil
    }
}
