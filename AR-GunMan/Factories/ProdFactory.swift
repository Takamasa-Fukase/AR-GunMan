//
//  ProdFactory.swift
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

final class ProdFactory: FactoryInterface {
    // MARK: Devices
    static func create(frame: CGRect, targetCount: Int) -> (ARShootingLibHandlerInterface, ARSCNViewRepresentable) {
        let (arShootingController, arView) = ARShootingLibBuilder.build(
            frame: frame,
            targetCount: targetCount
        )
        let arShootingLibHandler = ARShootingLibHandler(
            arShootingController: arShootingController
        )
        return (arShootingLibHandler, arView)
    }
    
    static func create() -> CameraPermissionHandlerInterface {
        return CameraPermissionHandler()
    }
    
    static func create() -> CoreMotionHandlerInterface {
        return CoreMotionHandler()
    }

    static func create() -> SoundPlayerInterface {
        return SoundPlayer.shared
    }
    
    // MARK: Storages
    static func create() -> FirestoreClientInterface {
        return FirestoreClient()
    }
    
    static func create() -> UserDefaultsDataSourceInterface {
        return UserDefaultsDataSource()
    }
    
    static func create() -> TutorialRepositoryInterface {
        return TutorialRepository(userDefaultsDataSource: create())
    }
    
    static func create() -> RankingRepositoryInterface {
        return RankingRepository(firestoreClient: create())
    }
    
    // MARK: UseCases
    static func create() -> RankingUseCaseInterface {
        return RankingUseCase(rankingRepository: create())
    }
    
    static func create() -> WeaponControlMotionHandleUseCaseInterface {
        return WeaponControlMotionHandleUseCase()
    }
}
