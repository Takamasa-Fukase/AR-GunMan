//
//  GameUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/03/25.
//

import RxSwift
import SceneKit

protocol GameUseCaseInterface {
    func startAccelerometerAndGyroUpdate() -> Observable<Void>
    func stopAccelerometerAndGyroUpdate() -> Observable<Void>
    func getFiringMotionStream() -> Observable<Void>
    func getReloadingMotionStream() -> Observable<Void>
    func getIsTutorialSeen() -> Observable<Bool>
    func setTutorialAlreadySeen() -> Observable<Void>
    func setupSceneViewAndNodes() -> Observable<Void>
    func getSceneView() -> Observable<UIView>
    func startSession() -> Observable<Void>
    func pauseSession() -> Observable<Void>
    func awaitGameStartSignal() -> Observable<Void>
    func awaitShowResultSignal() -> Observable<Void>
    func awaitWeaponReloadEnds(currentWeapon: WeaponType) -> Observable<Void>
    func getTimeCountStream() -> Observable<Double>
    func showWeapon(_ type: WeaponType) -> Observable<WeaponType>
    func fireWeapon() -> Observable<Void>
    func executeSecretEvent() -> Observable<Void>
    func getRendererUpdateStream() -> Observable<Void>
    func getCollisionOccurrenceStream() -> Observable<SCNPhysicsContact>
    func moveWeaponToFPSPosition(currentWeapon: WeaponType) -> Observable<Void>
    func checkTargetHit(contact: SCNPhysicsContact) -> Observable<(Bool, SCNPhysicsContact)>
    func removeContactedNodes(contact: SCNPhysicsContact) -> Observable<Void>
    func showTargetHitParticleToContactPoint(currentWeapon: WeaponType, contact: SCNPhysicsContact) -> Observable<Void>
}

final class GameUseCase: GameUseCaseInterface {
    private let coreMotionRepository: CoreMotionRepositoryInterface
    private let tutorialRepository: TutorialRepositoryInterface
    private let gameSceneRepository: GameSceneRepositoryInterface
    private let timerRepository: TimerRepositoryInterface
    
    init(
        coreMotionRepository: CoreMotionRepositoryInterface,
        tutorialRepository: TutorialRepositoryInterface,
        gameSceneRepository: GameSceneRepositoryInterface,
        timerRepository: TimerRepositoryInterface
    ) {
        self.coreMotionRepository = coreMotionRepository
        self.tutorialRepository = tutorialRepository
        self.gameSceneRepository = gameSceneRepository
        self.timerRepository = timerRepository
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
    
    func setupSceneViewAndNodes() -> Observable<Void> {
        return gameSceneRepository.setupSceneViewAndNodes()
    }

    func getSceneView() -> Observable<UIView> {
        return gameSceneRepository.getSceneView()
    }
    
    func startSession() -> Observable<Void> {
        return gameSceneRepository.startSession()
    }
    
    func pauseSession() -> Observable<Void> {
        return gameSceneRepository.pauseSession()
    }
    
    func awaitGameStartSignal() -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: GameConst.gameStartWaitingTimeMillisec,
                isRepeatd: false
            )
            .map({ _ in })
    }

    func awaitShowResultSignal() -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: GameConst.showResultWaitingTimeMillisec,
                isRepeatd: false
            )
            .map({ _ in })
    }
    
    func awaitWeaponReloadEnds(currentWeapon: WeaponType) -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: currentWeapon.reloadDurationMillisec,
                isRepeatd: false
            )
            .map({ _ in })
    }
    
    func getTimeCountStream() -> Observable<Double> {
        return timerRepository
            .getTimerStream(
                milliSec: GameConst.timeCountUpdateDurationMillisec,
                isRepeatd: true
            )
            .map({ timerUpdatedCount in // タイマーが更新された回数を表すInt
                // 例: 30.00 - (1 / 100) => 29.99
                return max(GameConst.timeCount - (Double(timerUpdatedCount) / 100), 0)
            })
    }
    
    func showWeapon(_ type: WeaponType) -> Observable<WeaponType> {
        return gameSceneRepository.showWeapon(type)
    }
    
    func fireWeapon() -> Observable<Void> {
        return gameSceneRepository.fireWeapon()
    }
    
    func executeSecretEvent() -> Observable<Void> {
        return gameSceneRepository.changeTargetsToTaimeisan()
    }
    

    func getRendererUpdateStream() -> Observable<Void> {
        return gameSceneRepository.getRendererUpdateStream()
    }
    
    func getCollisionOccurrenceStream() -> Observable<SCNPhysicsContact> {
        return gameSceneRepository.getCollisionOccurrenceStream()
    }
    
    func moveWeaponToFPSPosition(currentWeapon: WeaponType) -> Observable<Void> {
        return gameSceneRepository.moveWeaponToFPSPosition(currentWeapon: currentWeapon)
    }
    
    func checkTargetHit(contact: SCNPhysicsContact) -> Observable<(Bool, SCNPhysicsContact)> {
        return gameSceneRepository.checkTargetHit(contact: contact)
    }
    
    func removeContactedNodes(contact: SCNPhysicsContact) -> Observable<Void> {
        return gameSceneRepository.removeContactedNodes(
            nodeA: contact.nodeA, 
            nodeB: contact.nodeB
        )
    }
    
    func showTargetHitParticleToContactPoint(currentWeapon: WeaponType, contact: SCNPhysicsContact) -> Observable<Void> {
        return gameSceneRepository.showTargetHitParticleToContactPoint(
            currentWeapon: currentWeapon,
            contactPoint: contact.contactPoint
        )
    }
        
    private func getCompositeValue(x: Double, y: Double, z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
