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
    static func create(frame: CGRect, targetCount: Int) -> (ARGameEngineHandlerInterface, ARSCNViewRepresentable) {
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
    
    static func create() -> MotionSensorHandlerInterface {
        return CoreMotionHandler()
    }

    static func create() -> SoundPlayerInterface {
        return SoundPlayer.shared
    }
    
    // MARK: Storages
    static func create() -> FirestoreClientInterface {
        return FirestoreClient()
    }
    
    static func create() -> UserDefaultsClientInterface {
        return UserDefaultsClient()
    }
    
    static func create() -> TutorialRepositoryInterface {
        return TutorialRepository(userDefaultsClient: create())
    }
    
    static func create() -> RankingRepositoryInterface {
        return RankingRepository(firestoreClient: create())
    }
    
    // MARK: UseCases
//    static func create() -> RankingUseCaseInterface {
//        return RankingUseCase(rankingRepository: create())
//    }
    
    static func create() -> WeaponControlMotionDetectUseCaseInterface {
        return WeaponControlMotionDetectUseCase()
    }
}
