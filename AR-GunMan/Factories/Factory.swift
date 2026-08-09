//
//  Factory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/3/25.
//

import Foundation
import ARShootingLib
import Data
import DeviceInterface
import Domain
import Infrastructure

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
    static func create(frame: CGRect, targetCount: Int) -> (ARGameEngineHandlerInterface, ARSCNViewRepresentable)
    static func create() -> CameraPermissionHandlerInterface
    static func create() -> MotionSensorHandlerInterface
    static func create() -> SoundPlayerInterface

    // MARK: Storages
    static func create() -> FirestoreClientInterface
    static func create() -> UserDefaultsClientInterface
    
    // MARK: Repositories
    static func create() -> TutorialRepositoryInterface
    static func create() -> RankingRepositoryInterface
    
    // MARK: UseCases
    static func create() -> RankingGetUseCaseInterface
    static func create() -> RankingRegisterUseCaseInterface
    static func create() -> WeaponControlMotionDetectUseCaseInterface
}
