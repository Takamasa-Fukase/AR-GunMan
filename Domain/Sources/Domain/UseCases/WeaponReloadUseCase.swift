//
//  WeaponReloadUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

@MainActor
public protocol WeaponReloadUseCaseInterface {
    var startResultStream: AsyncStream<WeaponReloadStartResult> { get }
    func execute()
}

extension WeaponReloadUseCaseInterface {
    func stopCurrentReloadIfExists() {}
}

@MainActor
public final class WeaponReloadUseCase: WeaponReloadUseCaseInterface {
    public let startResultStream: AsyncStream<WeaponReloadStartResult>
    
    private var weaponStore: WeaponStoreInterface
    private let startResultContinuation: AsyncStream<WeaponReloadStartResult>.Continuation
    private var reloadTask: Task<Void, Never>?

    public init(weaponStore: WeaponStoreInterface) {
        self.weaponStore = weaponStore

        (startResultStream, startResultContinuation) = AsyncStream.makeStream()
    }
    
    public func execute() {
        let startResult = weaponStore.weapon.startReload()
        startResultContinuation.yield(startResult)

        let reloadWaitingTimeMillisec = weaponStore.weapon.currentType.reloadWaitingTimeMillisec
        reloadTask = Task {
            try? await Task.sleep(for: .milliseconds(reloadWaitingTimeMillisec))
            weaponStore.weapon.finishReload()
        }
    }
    
    func stopCurrentReloadIfExists() {
        reloadTask?.cancel()
        reloadTask = nil
    }
}
