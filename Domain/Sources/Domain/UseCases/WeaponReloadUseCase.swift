//
//  WeaponReloadUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public protocol WeaponReloadUseCaseInterface {
    var startResultStream: AsyncStream<WeaponReloadStartResult> { get }
    func execute()
}

extension WeaponReloadUseCaseInterface {
    func stopCurrentReloadIfExists() {}
}

public final class WeaponReloadUseCase: WeaponReloadUseCaseInterface {
    public let startResultStream: AsyncStream<WeaponReloadStartResult>
    
    private var weaponRepository: WeaponRepositoryInterface
    private let startResultContinuation: AsyncStream<WeaponReloadStartResult>.Continuation
    private var reloadTask: Task<Void, Never>?

    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
        
        (startResultStream, startResultContinuation) = AsyncStream.makeStream()
    }
    
    public func execute() {
        let startResult = weaponRepository.startReload()
        startResultContinuation.yield(startResult)

        let reloadWaitingTimeMillisec = weaponRepository.weaponType.weaponInfo.spec.reloadWaitingTimeMillisec
        reloadTask = Task {
            try? await Task.sleep(for: .milliseconds(reloadWaitingTimeMillisec))
            weaponRepository.finishReload()
        }
    }
    
    func stopCurrentReloadIfExists() {
        reloadTask?.cancel()
        reloadTask = nil
    }
}
