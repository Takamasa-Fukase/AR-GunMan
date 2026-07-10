//
//  WeaponReloadUseCase.swift
//  Domain
//
//  Created by ウルトラ深瀬 on 2026/07/07.
//

import Foundation

public protocol WeaponReloadUseCaseInterface {
    func execute() -> WeaponReloadUseCase.Response
}

public final class WeaponReloadUseCase: WeaponReloadUseCaseInterface {
    public struct Response {
        public let reloadTask: Task<Void, Never>
        public let startResult: WeaponReloadStartResult
    }
    
    private var weaponRepository: WeaponRepositoryInterface

    public init(weaponRepository: WeaponRepositoryInterface) {
        self.weaponRepository = weaponRepository
    }
    
    public func execute() -> Response {
        let startResult = weaponRepository.weapon.startReload()
        let reloadWaitingTimeMillisec = weaponRepository.weapon.currentType.weaponInfo.spec.reloadWaitingTimeMillisec
        
        print("WeaponReloadUseCase started")
        
        let task = Task {
            try? await Task.sleep(for: .milliseconds(reloadWaitingTimeMillisec))
            self.weaponRepository.weapon.finishReload()
            
            print("WeaponReloadUseCase finished")
        }
        return Response(
            reloadTask: task,
            startResult: startResult
        )
    }
}
