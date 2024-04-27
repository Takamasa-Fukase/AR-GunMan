//
//  GameUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/03/25.
//

import RxSwift

protocol GameUseCaseInterface {
    func startAccelerometerAndGyroUpdate()
    func stopAccelerometerAndGyroUpdate()
    func getFiringMotionStream() -> Observable<Void>
    func getReloadingMotionStream() -> Observable<Void>
    func getIsTutorialSeen() -> Observable<Bool>
    func setTutorialAlreadySeen() -> Observable<Void>
}

final class GameUseCase: GameUseCaseInterface {
    private let coreMotionRepository: CoreMotionRepositoryInterface
    private let tutorialRepository: TutorialRepositoryInterface
    
    init(
        coreMotionRepository: CoreMotionRepositoryInterface,
        tutorialRepository: TutorialRepositoryInterface
    ) {
        self.coreMotionRepository = coreMotionRepository
        self.tutorialRepository = tutorialRepository
    }
    
    func startAccelerometerAndGyroUpdate() {
        self.coreMotionRepository.startUpdate()
    }
    
    func stopAccelerometerAndGyroUpdate() {
        self.coreMotionRepository.stopUpdate()
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

    private func getCompositeValue(x: Double, y: Double, z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
