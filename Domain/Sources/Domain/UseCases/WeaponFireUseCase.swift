//
//  WeaponFireUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

@MainActor
public protocol WeaponFireUseCaseInterface {
    var resultStream: AsyncStream<WeaponFireResult> { get }
    func execute()
}

@MainActor
public final class WeaponFireUseCase: WeaponFireUseCaseInterface {
    public let resultStream: AsyncStream<WeaponFireResult>
    
    private var weaponRepository: WeaponRepositoryInterface
    private let weaponReloadUseCase: WeaponReloadUseCaseInterface
    private let resultContinuation: AsyncStream<WeaponFireResult>.Continuation

    public init(
        weaponRepository: WeaponRepositoryInterface,
        weaponReloadUseCase: WeaponReloadUseCaseInterface
    ) {
        self.weaponRepository = weaponRepository
        self.weaponReloadUseCase = weaponReloadUseCase
        
        (resultStream, resultContinuation) = AsyncStream.makeStream()
    }
    
    public func execute() {
        let result = weaponRepository.fire()
        resultContinuation.yield(result)
        if result == .success && weaponRepository.weaponType.reloadType == .auto {
            // リロードを自動的に実行
            weaponReloadUseCase.execute()
        }
    }
}
