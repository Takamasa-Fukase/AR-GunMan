//
//  GameUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/03/25.
//

import RxSwift

protocol GameUseCaseInterface {
    func startAccelerometerAndGyroUpdate() -> Observable<Void>
    func stopAccelerometerAndGyroUpdate() -> Observable<Void>
    func getFiringMotionStream() -> Observable<Void>
    func getReloadingMotionStream() -> Observable<Void>
    func getIsTutorialSeen() -> Observable<Bool>
    func setTutorialAlreadySeen() -> Observable<Void>
    func getSceneView() -> Observable<UIView>
    func startSession()
    func pauseSession()
    func awaitGameStartSignal() -> Observable<Void>
    func awaitShowResultSignal() -> Observable<Void>
    func showWeapon(_ type: WeaponType)
    func fireWeapon()
    func executeSecretEvent()
    func getTargetHitStream() -> Observable<Void>
}

final class GameUseCase: GameUseCaseInterface {
    private let coreMotionRepository: CoreMotionRepositoryInterface
    private let tutorialRepository: TutorialRepositoryInterface
    private let gameSceneRepository: GameSceneRepositoryInterface
    
    init(
        coreMotionRepository: CoreMotionRepositoryInterface,
        tutorialRepository: TutorialRepositoryInterface,
        gameSceneRepository: GameSceneRepositoryInterface
    ) {
        self.coreMotionRepository = coreMotionRepository
        self.tutorialRepository = tutorialRepository
        self.gameSceneRepository = gameSceneRepository
    }
    
    func startAccelerometerAndGyroUpdate() -> Observable<Void> {
        return self.coreMotionRepository.startUpdate()
    }
    
    func stopAccelerometerAndGyroUpdate() -> Observable<Void> {
        return self.coreMotionRepository.stopUpdate()
    }

    func getFiringMotionStream() -> Observable<Void> {
        return coreMotionRepository.getAccelerationStream()
            .withLatestFrom(coreMotionRepository.getGyroStream()) { ($0, $1) }
            .map{ (acceleration, gyro) in
                return (
                    self.getCompositeValue(x: 0, y: acceleration.y, z: acceleration.z),
                    self.getCompositeValue(x: 0, y: 0, z: gyro.z)
                )
            }
            .filter { (accelerationCompositeValue, gyroCompositeValue) in
                return accelerationCompositeValue >= 1.5 && gyroCompositeValue < 10
            }
            .map({_ in})
    }
    
    func getReloadingMotionStream() -> Observable<Void> {
        return coreMotionRepository.getGyroStream()
            .map{ gyro in
                return self.getCompositeValue(x: 0, y: 0, z: gyro.z)
            }
            .filter { gyroCompositeValue in
                gyroCompositeValue >= 10
            }
            .map({_ in})
    }
    
    func getIsTutorialSeen() -> Observable<Bool> {
        return tutorialRepository.getIsTutorialSeen()
    }
    
    func setTutorialAlreadySeen() -> Observable<Void> {
        return tutorialRepository.setTutorialAlreadySeen()
    }
    
    func getSceneView() -> Observable<UIView> {
        return gameSceneRepository.getSceneView()
    }
    
    func startSession() {
        gameSceneRepository.startSession()
    }
    
    func pauseSession() {
        gameSceneRepository.pauseSession()
    }
    
    func awaitGameStartSignal() -> Observable<Void> {
        return gameSceneRepository.awaitGameStartSignal()
    }

    func awaitShowResultSignal() -> Observable<Void> {
        return gameSceneRepository.awaitShowResultSignal()
    }
    
    func showWeapon(_ type: WeaponType) {
        gameSceneRepository.showWeapon(type)
    }
    
    func fireWeapon() {
        gameSceneRepository.fireWeapon()
    }
    
    func executeSecretEvent() {
        gameSceneRepository.changeTargetsToTaimeisan()
    }
    
    func getTargetHitStream() -> Observable<Void> {
        return gameSceneRepository.getTargetHitStream()
    }
    
    private func getCompositeValue(x: Double, y: Double, z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
