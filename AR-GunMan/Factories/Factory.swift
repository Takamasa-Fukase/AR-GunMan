//
//  Factory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/3/25.
//

import Foundation
import ARShootingLib
import Data
import Domain
import Infrastructure

#if DEBUG
// TODO: FirebaseはProdとDevで両方用意してあるので、ビルド環境にMockを用意して、Prod, Dev, Mockみたいに3つに分けたい
typealias Factory = MockFactory
#else
typealias Factory = ProdFactory
#endif

protocol FactoryInterface {
    // MARK: Devices
    static func create(frame: CGRect, targetCount: Int) -> (ARShootingLibHandlerInterface, ARSCNViewRepresentable)
    static func create() -> CameraPermissionHandlerInterface
    static func create() -> CoreMotionHandlerInterface
    static func create() -> SoundPlayerInterface

    // MARK: Storages
    static func create() -> FirestoreClientInterface
    static func create() -> UserDefaultsDataSourceInterface
    static func create() -> WeaponDataSourceInterface
    
    // MARK: Repositories
    static func create() -> WeaponRepositoryInterface
    static func create() -> TutorialRepositoryInterface
    static func create() -> RankingRepositoryInterface
    
    // MARK: UseCases
    static func create() -> GameTimerCreateUseCaseInterface
    static func create() -> RankingUseCaseInterface
    static func create() -> WeaponActionExecuteUseCaseInterface
    static func create() -> WeaponControlMotionHandleUseCaseInterface
    static func create() -> WeaponResourceGetUseCaseInterface
    static func create() -> WeaponStatusCheckUseCaseInterface
}
