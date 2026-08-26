//
//  ProdFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/3/25.
//

import Foundation
import ARShootingEngine
import Data
import Device
import Domain

@MainActor
final class ProdFactory: FactoryInterface {
    // MARK: Devices
    static func create(frame: CGRect, targetCount: Int) -> (ARShootingEngineHandlerInterface, ARSCNViewRepresentable) {
        let (arShootingController, arView) = ARShootingEngineFactory.create(
            frame: frame,
            targetCount: targetCount
        )
        let arShootingEngineHandler = ARShootingEngineHandler(
            arShootingController: arShootingController
        )
        return (arShootingEngineHandler, arView)
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
    
    // MARK: Repositories
    static func create() -> TutorialRepositoryInterface {
        return TutorialRepository(userDefaultsClient: create())
    }
    
    static func create() -> RankingRepositoryInterface {
        return RankingRepository(firestoreClient: create())
    }
    
    // MARK: Stores
    static func create() -> RankingStoreInterface {
        return RankingStore.shared
    }
    
    static func create() -> WeaponStoreInterface {
        return WeaponStore.shared
    }
    
    static func create() -> GameStoreInterface {
        return GameStore.shared
    }
    
    // MARK: UseCases
    static func create() -> RankingGetUseCaseInterface {
        return RankingGetUseCase(
            rankingRepository: create(),
            rankingStore: create()
        )
    }
    
    static func create() -> RankingRegisterUseCaseInterface {
        return RankingRegisterUseCase(
            rankingRepository: create(),
            rankingStore: create()
        )
    }
    
    static func create(
        weaponReloadUseCase: WeaponReloadUseCaseInterface
    ) -> WeaponFireUseCaseInterface {
        return WeaponFireUseCase(
            weaponStore: create(),
            weaponReloadUseCase: weaponReloadUseCase
        )
    }
    
    static func create() -> WeaponReloadUseCaseInterface {
        return WeaponReloadUseCase(weaponStore: create())
    }
    
    static func create(
        weaponReloadUseCase: WeaponReloadUseCaseInterface
    ) -> WeaponChangeUseCaseInterface {
        return WeaponChangeUseCase(
            weaponStore: create(),
            weaponReloadUseCase: weaponReloadUseCase
        )
    }
    
    static func create() -> GameFlowDriveUseCaseInterface {
        return GameFlowDriveUseCase(
            tutorialRepository: create(),
            gameStore: create()
        )
    }
    
    static func create() -> ScoreAddUseCaseInterface {
        return ScoreAddUseCase(gameStore: create())
    }
    
    static func create() -> ReloadingMotionCountUpdateUseCaseInterface {
        return ReloadingMotionCountUpdateUseCase(gameStore: create())
    }
    
    static func create() -> WeaponControlMotionDetectUseCaseInterface {
        return WeaponControlMotionDetectUseCase()
    }
}
