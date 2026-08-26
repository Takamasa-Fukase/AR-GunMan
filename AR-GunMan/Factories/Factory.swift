//
//  Factory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/3/25.
//

import Foundation
import ARShootingEngine
import Data
import Device
import Domain

#if DEBUG
// TODO: FirebaseはProdとDevで両方用意してあるので、ビルド環境にMockを用意して、Prod, Dev, Mockみたいに3つに分けたい
//typealias Factory = MockFactory
typealias Factory = ProdFactory
#else
typealias Factory = ProdFactory
#endif

@MainActor
protocol FactoryInterface {
    // MARK: Devices
    static func create(frame: CGRect, targetCount: Int) -> (ARShootingEngineHandlerInterface, ARSCNViewRepresentable)
    static func create() -> CameraPermissionHandlerInterface
    static func create() -> MotionSensorHandlerInterface
    static func create() -> SoundPlayerInterface

    // MARK: Storages
    static func create() -> FirestoreClientInterface
    static func create() -> UserDefaultsClientInterface
    
    // MARK: Repositories
    static func create() -> TutorialRepositoryInterface
    static func create() -> RankingRepositoryInterface
    
    // MARK: Stores
    static func create() -> RankingStoreInterface
    static func create() -> WeaponStoreInterface
    static func create() -> GameStoreInterface
    
    // MARK: UseCases
    static func create() -> RankingGetUseCaseInterface
    static func create() -> RankingRegisterUseCaseInterface
    static func create(weaponReloadUseCase: WeaponReloadUseCaseInterface) -> WeaponFireUseCaseInterface
    static func create() -> WeaponReloadUseCaseInterface
    static func create(weaponReloadUseCase: WeaponReloadUseCaseInterface) -> WeaponChangeUseCaseInterface
    static func create() -> GameFlowDriveUseCaseInterface
    static func create() -> ScoreAddUseCaseInterface
    static func create() -> ReloadingMotionCountUpdateUseCaseInterface
    static func create() -> WeaponControlMotionDetectUseCaseInterface
}
