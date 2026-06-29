//
//  GamePresenter.swift
//  Presentation
//
//  Created by ウルトラ深瀬 on 2026/06/19.
//

import Foundation
import Combine
import Domain

public final class GamePresenter {
    public let timeCountPublisher: AnyPublisher<Double, Never>
    public let currentWeaponPublisher: AnyPublisher<CurrentWeapon?, Never>
    public let isWeaponChangeButtonEnabledPublisher: AnyPublisher<Bool, Never>
    public let isTutorialViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isWeaponSelectViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isResultViewPresentedPublisher: AnyPublisher<(Bool, Double), Never>
    
    private let arShootingLibHandler: ARShootingLibHandlerInterface
    private let soundPlayer: SoundPlayerInterface
    private let tutorialRepository: TutorialRepositoryInterface
    private let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface
    private let gameTimerCreateUseCase: GameTimerCreateUseCaseInterface
    private let weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface
    private let weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    private let timerPauseController = GameTimerCreateRequest.PauseController()
    private let weaponReloadCanceller = WeaponReloadCanceller()
    private let timeCountSubject = CurrentValueSubject<Double, Never>(30.00)
    private let currentWeaponSubject = CurrentValueSubject<CurrentWeapon?, Never>(nil)
    private let isWeaponChangeButtonEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let isTutorialViewPresentedSubject = CurrentValueSubject<Bool, Never>(false)
    private let isWeaponSelectViewPresentedSubject = CurrentValueSubject<Bool, Never>(false)
    private let isResultViewPresentedSubject = CurrentValueSubject<(Bool, Double), Never>((false, 0.0))
    private var isCheckedTutorialCompletedFlag = false
    private var reloadingMotionDetecedCount: Int = 0
    private var score: Double = 0
    
    public init(
        arShootingLibHandler: ARShootingLibHandlerInterface,
        soundPlayer: SoundPlayerInterface,
        tutorialRepository: TutorialRepositoryInterface,
        weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface,
        gameTimerCreateUseCase: GameTimerCreateUseCaseInterface,
        weaponResourceGetUseCase: WeaponResourceGetUseCaseInterface,
        weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    ) {
        self.arShootingLibHandler = arShootingLibHandler
        self.soundPlayer = soundPlayer
        self.tutorialRepository = tutorialRepository
        self.weaponControlMotionHandleUseCase = weaponControlMotionHandleUseCase
        self.gameTimerCreateUseCase = gameTimerCreateUseCase
        self.weaponResourceGetUseCase = weaponResourceGetUseCase
        self.weaponActionExecuteUseCase = weaponActionExecuteUseCase
        
        timeCountPublisher = timeCountSubject.eraseToAnyPublisher()
        currentWeaponPublisher = currentWeaponSubject.eraseToAnyPublisher()
        isWeaponChangeButtonEnabledPublisher = isWeaponChangeButtonEnabledSubject.eraseToAnyPublisher()
        isTutorialViewPresentedPublisher = isTutorialViewPresentedSubject.eraseToAnyPublisher()
        isWeaponSelectViewPresentedPublisher = isWeaponSelectViewPresentedSubject.eraseToAnyPublisher()
        isResultViewPresentedPublisher = isResultViewPresentedSubject.eraseToAnyPublisher()
    }
    
    // MARK: ViewからのInput
    public func onViewAppear() {
        let selectedWeapon = weaponResourceGetUseCase.getDefaultWeapon()
        showSelectedWeapon(selectedWeapon)
        
        arShootingLibHandler.runSession()
        
        if !isCheckedTutorialCompletedFlag {
            isCheckedTutorialCompletedFlag = true
            
            let isTutorialCompleted = tutorialRepository.getTutorialCompletedFlag()
            if isTutorialCompleted {
                waitAndCreateTimer()
            } else {
                isTutorialViewPresentedSubject.send(true)
            }
        }
    }
    
    public func onViewDisappear() {
        arShootingLibHandler.pauseSession()
    }
    
    public func tutorialEnded() {
        tutorialRepository.updateTutorialCompletedFlag(isCompleted: true)
        waitAndCreateTimer()
    }
    
    public func weaponChangeButtonTapped() {
        // 武器選択中はタイムカウントの更新を止める
        timerPauseController.isPaused = true
        isWeaponSelectViewPresentedSubject.send(true)
    }
    
    public func weaponSelected(weaponId: Int) {
        // タイムカウントの更新を再開する
        timerPauseController.isPaused = false
        // 既存のリロードをキャンセルする
        weaponReloadCanceller.isCancelled = true
        
        let selectedWeapon = weaponResourceGetUseCase.getWeapon(of: weaponId)
        showSelectedWeapon(selectedWeapon)
    }
    
    // MARK: Privateメソッド
    private func showSelectedWeapon(_ selectedWeapon: CurrentWeapon) {
        self.currentWeaponSubject.send(selectedWeapon)
        
        guard let currentWeapon = currentWeaponSubject.value else { return }
        
        // FIXME: 一時的な対応
        //        arShootingLibHandler.showWeapon(of: currentWeapon.weapon.id)
        if let weaponType = WeaponType.fromId(currentWeapon.weapon.id) {
            arShootingLibHandler.showWeapon(of: weaponType)
        }
                
        if isCheckedTutorialCompletedFlag {
            soundPlayer.play(currentWeapon.weapon.resources.appearingSound)
        }
    }
    
    private func waitAndCreateTimer() {
        guard let currentWeapon = currentWeaponSubject.value else { return }

        soundPlayer.play(currentWeapon.weapon.resources.appearingSound)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let request = GameTimerCreateRequest(
                initialTimeCount: self.timeCountSubject.value,
                updateInterval: 0.01,
                pauseController: self.timerPauseController
            )
            self.gameTimerCreateUseCase.execute(
                request: request,
                onTimerStarted: { [weak self] response in
                    self?.soundPlayer.play(response.startWhistleSound)
                    self?.weaponControlMotionHandleUseCase.startDetection()
                    self?.isWeaponChangeButtonEnabledSubject.send(true)
                },
                onTimerUpdated: { [weak self] response in
                    self?.timeCountSubject.send(response.timeCount)
                },
                onTimerEnded: { [weak self] response in
                    self?.soundPlayer.play(response.endWhistleSound)
                    self?.weaponControlMotionHandleUseCase.stopDetection()
                    self?.isWeaponChangeButtonEnabledSubject.send(false)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self?.soundPlayer.play(response.rankingAppearSound)
                        self?.isResultViewPresentedSubject.send((true, self?.score ?? 0.0))
                    })
                })
        })
    }
    
    private func fireWeapon() {
        guard let currentWeapon = currentWeaponSubject.value else { return }

        weaponActionExecuteUseCase.fireWeapon(
            bulletsCount: currentWeapon.state.bulletsCount,
            isReloading: currentWeapon.state.isReloading,
            reloadType: currentWeapon.weapon.spec.reloadType,
            onFired: { [weak self] response in
                var modifiedCurrentWeapon = currentWeapon
                modifiedCurrentWeapon.state.bulletsCount = response.bulletsCount
                self?.currentWeaponSubject.send(modifiedCurrentWeapon)
                self?.arShootingLibHandler.renderWeaponFiring()
                self?.soundPlayer.play(currentWeapon.weapon.resources.firingSound)
                
                if response.needsAutoReload {
                    // リロードを自動的に実行
                    self?.reloadingMotionDetected()
                }
            },
            onOutOfBullets: { [weak self] in
                if let outOfBulletsSound = currentWeapon.weapon.resources.outOfBulletsSound {
                    self?.soundPlayer.play(outOfBulletsSound)
                }
            })
    }
    
    private func reloadWeapon() {
        guard let currentWeapon = currentWeaponSubject.value else { return }

        // falseにリセット
        weaponReloadCanceller.isCancelled = false
        
        weaponActionExecuteUseCase.reloadWeapon(
            bulletsCount: currentWeapon.state.bulletsCount,
            isReloading: currentWeapon.state.isReloading,
            capacity: currentWeapon.weapon.spec.capacity,
            reloadWaitingTime: currentWeapon.weapon.spec.reloadWaitingTime,
            reloadCanceller: weaponReloadCanceller,
            onReloadStarted: { [weak self] response in
                var modifiedCurrentWeapon = currentWeapon
                modifiedCurrentWeapon.state.isReloading = response.isReloading
                self?.currentWeaponSubject.send(modifiedCurrentWeapon)
                self?.soundPlayer.play(currentWeapon.weapon.resources.reloadingSound)
            },
            onReloadEnded: { [weak self] response in
                var modifiedCurrentWeapon = currentWeapon
                modifiedCurrentWeapon.state.bulletsCount = response.bulletsCount
                modifiedCurrentWeapon.state.isReloading = response.isReloading
                self?.currentWeaponSubject.send(modifiedCurrentWeapon)
            })
    }
}

extension GamePresenter: ARShootingLibHandlerDelegate {
    public func targetHit() {
        guard let currentWeapon = currentWeaponSubject.value else { return }

        //ランキングがバラけるように、加算する得点自体に90%~100%の間の乱数を掛ける
        let randomlyAdjustedHitPoint = Double(currentWeapon.weapon.spec.targetHitPoint) * Double.random(in: 0.9...1)
        // 100を超えない様に更新する
        score = min(score + randomlyAdjustedHitPoint, 100.0)
        
        soundPlayer.play(.targetHit)
        
        if let bulletHitSound = currentWeapon.weapon.resources.bulletHitSound {
            soundPlayer.play(bulletHitSound)
        }
    }
}

extension GamePresenter: WeaponControlMotionHandleUseCaseDelegate {
    public func firingMotionDetected() {
        fireWeapon()
    }
    
    public func reloadingMotionDetected() {
        reloadWeapon()
        reloadingMotionDetecedCount += 1
        if reloadingMotionDetecedCount == 20 {
            soundPlayer.play(.targetAppearanceChange)
            arShootingLibHandler.changeTargetsAppearance(to: "taimeisan.jpg")
        }
    }
}
