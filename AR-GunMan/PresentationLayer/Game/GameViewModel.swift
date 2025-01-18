//
//  GameViewModel.swift
//  Sample_AR-GunMan_Replace_SwiftUI
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import Foundation
import Observation
import Combine
import DomainLayer

@Observable
final class GameViewModel {
    enum ARControllerInputEventType {
        case runSceneSession
        case pauseSceneSession
        case renderWeaponFiring
        case showWeaponObject(weaponId: Int)
        case changeTargetsAppearance(imageName: String)
    }
    enum MotionDetectorInputEventType {
        case startDeviceMotionDetection
        case stopDeviceMotionDetection
    }
    
    private(set) var timeCount: Double = 0.01
    private(set) var currentWeaponData: CurrentWeaponData?
    
    var isTutorialViewPresented = false
    var isWeaponSelectViewPresented = false
    var isResultViewPresented = false
    
    let arControllerInputEvent = PassthroughSubject<ARControllerInputEventType, Never>()
    let motionDetectorInputEvent = PassthroughSubject<MotionDetectorInputEventType, Never>()
    let playSound = PassthroughSubject<SoundType, Never>()
    
    private let tutorialUseCase: TutorialUseCaseInterface
    private let gameTimerCreateUseCase: GameTimerCreateUseCaseInterface
    private let weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface
    private let weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    private let timerPauseController = GameTimerCreateRequest.PauseController()
    private let weaponReloadCanceller = WeaponReloadCanceller()

    @ObservationIgnored private(set) var score: Double = 38.555
    @ObservationIgnored private var isCheckedTutorialCompletedFlag = false
    @ObservationIgnored private var reloadingMotionDetecedCount: Int = 0
    
    init(
        tutorialUseCase: TutorialUseCaseInterface,
        gameTimerCreateUseCase: GameTimerCreateUseCaseInterface,
        weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface,
        weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    ) {
        self.tutorialUseCase = tutorialUseCase
        self.gameTimerCreateUseCase = gameTimerCreateUseCase
        self.weaponResourceGetUseCase = weaponResourceGetUseCase
        self.weaponActionExecuteUseCase = weaponActionExecuteUseCase
    }
    
    // MARK: ViewからのInput
    func onViewAppear() {
        do {
            let selectedWeaponData = try weaponResourceGetUseCase.getDefaultWeaponDetail()
            showSelectedWeapon(selectedWeaponData)
            
        } catch {
            print("defaultWeaponGetUseCase error: \(error)")
        }
        
        arControllerInputEvent.send(.runSceneSession)
        
        if !isCheckedTutorialCompletedFlag {
            isCheckedTutorialCompletedFlag = true
            
            let isTutorialCompleted = tutorialUseCase.checkCompletedFlag()
            if isTutorialCompleted {
                waitAndCreateTimer()
            }else {
                isTutorialViewPresented = true
            }
        }
    }
    
    func onViewDisappear() {
        arControllerInputEvent.send(.pauseSceneSession)
    }
    
    func tutorialEnded() {
        tutorialUseCase.updateCompletedFlag(isCompleted: true)
        waitAndCreateTimer()
    }
    
    func fireMotionDetected() {
        fireWeapon()
    }
    
    func reloadMotionDetected() {
        reloadWeapon()
        reloadingMotionDetecedCount += 1
        if reloadingMotionDetecedCount == 20 {
            playSound.send(.targetAppearanceChange)
            arControllerInputEvent.send(.changeTargetsAppearance(imageName: "taimeisan.jpg"))
        }
    }
    
    func weaponChangeButtonTapped() {
        // 武器選択中はタイムカウントの更新を止める
        timerPauseController.isPaused = true
        isWeaponSelectViewPresented = true
    }
    
    func weaponSelected(weaponId: Int) {
        // タイムカウントの更新を再開する
        timerPauseController.isPaused = false
        // 既存のリロードをキャンセルする
        weaponReloadCanceller.isCancelled = true
        
        do {
            let selectedWeaponData = try weaponResourceGetUseCase.getWeaponDetail(of: weaponId)
            showSelectedWeapon(selectedWeaponData)
            
        } catch {
            print("WeaponDetailGetRequest error: \(error)")
        }
    }
    
    func targetHit() {
        //ランキングがバラけるように、加算する得点自体に90%~100%の間の乱数を掛ける
        let randomlyAdjustedHitPoint = Double(currentWeaponData?.spec.targetHitPoint ?? 0) * Double.random(in: 0.9...1)
        // 100を超えない様に更新する
        score = min(score + randomlyAdjustedHitPoint, 100.0)
        
        playSound.send(.targetHit)
        
        if let bulletHitSound = currentWeaponData?.resources.bulletHitSound {
            playSound.send(bulletHitSound)
        }
    }
    
    // MARK: Privateメソッド
    private func showSelectedWeapon(_ selectedWeaponData: CurrentWeaponData) {
        self.currentWeaponData = selectedWeaponData
        
        guard let currentWeaponData = self.currentWeaponData else { return }
        arControllerInputEvent.send(.showWeaponObject(weaponId: currentWeaponData.id))
        
        if isCheckedTutorialCompletedFlag {
            playSound.send(currentWeaponData.resources.appearingSound)
        }
    }
    
    private func waitAndCreateTimer() {
        guard let currentWeaponData = self.currentWeaponData else { return }
        playSound.send(currentWeaponData.resources.appearingSound)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [weak self] in
            let request = GameTimerCreateRequest(
                initialTimeCount: 0.01,
                updateInterval: 0.01,
                pauseController: self?.timerPauseController ?? .init()
            )
            self?.gameTimerCreateUseCase.execute(
                request: request,
                onTimerStarted: { [weak self] response in
                    self?.playSound.send(response.startWhistleSound)
                    self?.motionDetectorInputEvent.send(.startDeviceMotionDetection)
                },
                onTimerUpdated: { [weak self] response in
                    self?.timeCount = response.timeCount
                },
                onTimerEnded: { [weak self] response in
                    self?.playSound.send(response.endWhistleSound)
                    self?.motionDetectorInputEvent.send(.stopDeviceMotionDetection)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [weak self] in
                        self?.playSound.send(response.rankingAppearSound)
                        self?.isResultViewPresented = true
                    })
                })
        })
    }
    
    private func fireWeapon() {
        weaponActionExecuteUseCase.fireWeapon(
            bulletsCount: currentWeaponData?.state.bulletsCount ?? 0,
            isReloading: currentWeaponData?.state.isReloading ?? false,
            reloadType: currentWeaponData?.spec.reloadType ?? .manual,
            onFired: { response in
                currentWeaponData?.state.bulletsCount = response.bulletsCount
                arControllerInputEvent.send(.renderWeaponFiring)
                playSound.send(currentWeaponData?.resources.firingSound ?? .pistolFire)
                
                if response.needsAutoReload {
                    // リロードを自動的に実行
                    reloadWeapon()
                }
            },
            onOutOfBullets: {
                if let outOfBulletsSound = currentWeaponData?.resources.outOfBulletsSound {
                    playSound.send(outOfBulletsSound)
                }
            })
    }
    
    private func reloadWeapon() {
        // falseにリセット
        weaponReloadCanceller.isCancelled = false
        
        weaponActionExecuteUseCase.reloadWeapon(
            bulletsCount: currentWeaponData?.state.bulletsCount ?? 0,
            isReloading: currentWeaponData?.state.isReloading ?? false,
            capacity: currentWeaponData?.spec.capacity ?? 0,
            reloadWaitingTime: currentWeaponData?.spec.reloadWaitingTime ?? 0,
            reloadCanceller: weaponReloadCanceller,
            onReloadStarted: { response in
                currentWeaponData?.state.isReloading = response.isReloading
                playSound.send(currentWeaponData?.resources.reloadingSound ?? .pistolReload)
            },
            onReloadEnded: { [weak self] response in
                self?.currentWeaponData?.state.bulletsCount = response.bulletsCount
                self?.currentWeaponData?.state.isReloading = response.isReloading
            })
    }
}
