//
//  MockFactory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/3/25.
//

import Foundation
import ARShootingLib
import Data
import DeviceInterface
import Domain
import Presentation
import Infrastructure

@MainActor
final class MockFactory: FactoryInterface {
    // MARK: Devices
    static func create(frame: CGRect, targetCount: Int) -> (ARGameEngineHandlerInterface, ARSCNViewRepresentable) {
        let mockController = ARShootingControllerMock()
        let arShootingLibHandler = ARShootingLibHandler(arShootingController: mockController)
        let mockARView = ARSCNViewRepresentable.createMock()
        return (arShootingLibHandler, mockARView)
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
        return RankingRepositoryStub()
    }
    
    // MARK: UseCases
    static func create() -> RankingGetUseCaseInterface {
        return RankingGetUseCase(
            rankingRepository: create(),
            rankingStore: RankingStore.shared
        )
    }
    
    static func create() -> RankingRegisterUseCaseInterface {
        return RankingRegisterUseCase(
            rankingRepository: create(),
            rankingStore: RankingStore.shared
        )
    }
    
    static func create() -> WeaponControlMotionDetectUseCaseInterface {
        return WeaponControlMotionDetectUseCase()
    }
}
