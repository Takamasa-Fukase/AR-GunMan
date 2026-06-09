//
//  MockFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/3/25.
//

import Foundation
import ARShootingLib
import Data
import Domain
import Infrastructure

final class MockFactory: FactoryInterface {
    // MARK: Devices
    static func create(frame: CGRect, targetCount: Int) -> (ARShootingLibHandlerInterface, ARSCNViewRepresentable) {
        let arShootingController = ARShootingControllerMock()
        let arShootingLibHandler = ARShootingLibHandler(
            arShootingController: arShootingController
        )
        let arView = arShootingController.getARView()
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
    
    static func create() -> WeaponDataSourceInterface {
        return WeaponDataSource()
    }
    
    // MARK: Repositories
    static func create() -> WeaponRepositoryInterface {
        return WeaponRepository(weaponDataSource: create())
    }
    
    static func create() -> TutorialRepositoryInterface {
        return TutorialRepository(userDefaultsDataSource: create())
    }
    
    static func create() -> RankingRepositoryInterface {
        return RankingRepositoryStub()
    }
    
    // MARK: UseCases
    static func create() -> GameTimerCreateUseCaseInterface {
        return GameTimerCreateUseCase()
    }
    
    static func create() -> RankingUseCaseInterface {
        return RankingUseCase(rankingRepository: create())
    }
    
    static func create() -> WeaponActionExecuteUseCaseInterface {
        return WeaponActionExecuteUseCase(weaponStatusCheckUseCase: create())
    }
    
    static func create() -> WeaponControlMotionHandleUseCaseInterface {
        return WeaponControlMotionHandleUseCase(coreMotionHandler: create())
    }

    static func create() -> WeaponResourceGetUseCaseInterface {
        return WeaponResourceGetUseCase(weaponRepository: create())
    }
    
    static func create() -> WeaponStatusCheckUseCaseInterface {
        return WeaponStatusCheckUseCase()
    }
}
