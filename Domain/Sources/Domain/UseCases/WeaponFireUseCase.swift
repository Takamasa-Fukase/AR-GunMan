//
//  WeaponFireUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public protocol WeaponFireUseCaseInterface {
    func execute()
}

public final class WeaponFireUseCase: WeaponFireUseCaseInterface {
    public struct State {
        public let bulletsCount: Int
    }
    public struct Event {
        public let weaponType: WeaponType
        public let result: WeaponFireResult
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
        let result = weapon.fire()
        let event = Event(
            weaponType: weapon.currentType,
            result: result
        )
        eventContinuation?.yield(event)
    }
}
