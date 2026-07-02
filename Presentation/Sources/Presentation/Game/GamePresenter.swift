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
    // FIXME: 一旦ビルド通るように簡易的に対応している
    public let currentWeaponPublisher: AnyPublisher<LoadedWeapon?, Never>
    public let isWeaponChangeButtonEnabledPublisher: AnyPublisher<Bool, Never>
    public let isTutorialViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isWeaponSelectViewPresentedPublisher: AnyPublisher<Bool, Never>
    public let isResultViewPresentedPublisher: AnyPublisher<(Bool, Double), Never>
    
    private let arShootingLibHandler: ARShootingLibHandlerInterface
    private let soundPlayer: SoundPlayerInterface
    private let tutorialRepository: TutorialRepositoryInterface
    private let weaponControlMotionHandleUseCase: WeaponControlMotionHandleUseCaseInterface
    private let gameTimerCreateUseCase: GameTimerCreateUseCaseInterface
    private let weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    private let timerPauseController = GameTimerCreateRequest.PauseController()
    private let weaponReloadCanceller = WeaponReloadCanceller()
    private let timeCountSubject = CurrentValueSubject<Double, Never>(30.00)
    private let currentWeaponSubject = CurrentValueSubject<LoadedWeapon?, Never>(nil)
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
        weaponActionExecuteUseCase: WeaponActionExecuteUseCaseInterface
    ) {
        self.arShootingLibHandler = arShootingLibHandler
        self.soundPlayer = soundPlayer
        self.tutorialRepository = tutorialRepository
        self.weaponControlMotionHandleUseCase = weaponControlMotionHandleUseCase
        self.gameTimerCreateUseCase = gameTimerCreateUseCase
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
        // FIXME: 暫定
        guard let defaultWeaponType = WeaponType.allCases.first(where: { $0.weaponInfo.isDefault }) else {
            fatalError("デフォルトの武器が見つかりません")
        }
        let defaultWeapon = LoadedWeapon(
            weaponType: defaultWeaponType,
            bulletsCount: defaultWeaponType.weaponInfo.spec.capacity,
            isReloading: false
        )
        showSelectedWeapon(defaultWeapon)
        
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
        
        // FIXME: 暫定
        guard let selectedWeapoType = WeaponType.fromId(weaponId) else {
            fatalError("WeaponType.fromId(weaponId)失敗")
        }
        let selectedWeapon = LoadedWeapon(
            weaponType: selectedWeapoType,
            bulletsCount: selectedWeapoType.weaponInfo.spec.capacity,
            isReloading: false
        )
        showSelectedWeapon(selectedWeapon)
    }
    
    // MARK: Privateメソッド
    private func showSelectedWeapon(_ selectedWeapon: LoadedWeapon) {
        self.currentWeaponSubject.send(selectedWeapon)
        
        guard let currentWeapon = currentWeaponSubject.value else { return }
        
        // FIXME: 一時的な対応
        //        arShootingLibHandler.showWeapon(of: currentWeapon.weapon.id)
        if let weaponType = WeaponType.fromId(currentWeapon.weaponType.id) {
            arShootingLibHandler.showWeapon(of: weaponType)
        }
                
        if isCheckedTutorialCompletedFlag {
            // FIXME: 暫定　本来はPre層では音声種別は持たない。
            soundPlayer.play(currentWeapon.weaponType.resources.appearingSound)
        }
    }
    
    private func waitAndCreateTimer() {
        guard let currentWeapon = currentWeaponSubject.value else { return }

        soundPlayer.play(currentWeapon.weaponType.resources.appearingSound)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let request = GameTimerCreateRequest(
                initialTimeCount: self.timeCountSubject.value,
                updateInterval: 0.01,
                pauseController: self.timerPauseController
            )
            self.gameTimerCreateUseCase.execute(
                request: request,
                onTimerStarted: { [weak self] in
                    self?.soundPlayer.play(.startWhistle)
                    self?.weaponControlMotionHandleUseCase.startDetection()
                    self?.isWeaponChangeButtonEnabledSubject.send(true)
                },
                onTimerUpdated: { [weak self] response in
                    self?.timeCountSubject.send(response.timeCount)
                },
                onTimerEnded: { [weak self] in
                    self?.soundPlayer.play(.endWhistle)
                    self?.weaponControlMotionHandleUseCase.stopDetection()
                    self?.isWeaponChangeButtonEnabledSubject.send(false)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self?.soundPlayer.play(.rankingAppear)
                        self?.isResultViewPresentedSubject.send((true, self?.score ?? 0.0))
                    })
                })
        })
    }
    
    private func fireWeapon() {
        guard let currentWeapon = currentWeaponSubject.value else { return }

        weaponActionExecuteUseCase.fireWeapon(
            bulletsCount: currentWeapon.bulletsCount,
            isReloading: currentWeapon.isReloading,
            reloadType: currentWeapon.weaponType.weaponInfo.spec.reloadType,
            onFired: { [weak self] response in
                var modifiedCurrentWeapon = currentWeapon
                modifiedCurrentWeapon.bulletsCount = response.bulletsCount
                self?.currentWeaponSubject.send(modifiedCurrentWeapon)
                self?.arShootingLibHandler.renderWeaponFiring()
                self?.soundPlayer.play(currentWeapon.weaponType.resources.firingSound)
                
                if response.needsAutoReload {
                    // リロードを自動的に実行
                    self?.reloadingMotionDetected()
                }
            },
            onOutOfBullets: { [weak self] in
                if let outOfBulletsSound = currentWeapon.weaponType.resources.outOfBulletsSound {
                    self?.soundPlayer.play(outOfBulletsSound)
                }
            })
    }
    
    private func reloadWeapon() {
        guard let currentWeapon = currentWeaponSubject.value else { return }

        // falseにリセット
        weaponReloadCanceller.isCancelled = false
        
        weaponActionExecuteUseCase.reloadWeapon(
            bulletsCount: currentWeapon.bulletsCount,
            isReloading: currentWeapon.isReloading,
            capacity: currentWeapon.weaponType.weaponInfo.spec.capacity,
            reloadWaitingTime: currentWeapon.weaponType.weaponInfo.spec.reloadWaitingTime,
            reloadCanceller: weaponReloadCanceller,
            onReloadStarted: { [weak self] response in
                var modifiedCurrentWeapon = currentWeapon
                modifiedCurrentWeapon.isReloading = response.isReloading
                self?.currentWeaponSubject.send(modifiedCurrentWeapon)
                self?.soundPlayer.play(currentWeapon.weaponType.resources.reloadingSound)
            },
            onReloadEnded: { [weak self] response in
                var modifiedCurrentWeapon = currentWeapon
                modifiedCurrentWeapon.bulletsCount = response.bulletsCount
                modifiedCurrentWeapon.isReloading = response.isReloading
                self?.currentWeaponSubject.send(modifiedCurrentWeapon)
            })
    }
}

extension GamePresenter: ARShootingLibHandlerDelegate {
    public func targetHit() {
        guard let currentWeapon = currentWeaponSubject.value else { return }

        // TODO: スコア自体の保持がGameSessionRepo経由のGameSessionStoreになったら、計算＆加算をまとめてUseCaseにする
        //ランキングがバラけるように、加算する得点自体に90%~100%の間の乱数を掛ける
        let randomlyAdjustedHitPoint = Double(currentWeapon.weaponType.weaponInfo.spec.targetHitPoint) * Double.random(in: 0.9...1)
        // 100を超えない様に更新する
        score = min(score + randomlyAdjustedHitPoint, 100.0)
        
        // TODO: 下記などの音声再生処理は要検討
        soundPlayer.play(.targetHit)
        
        if let bulletHitSound = currentWeapon.weaponType.resources.bulletHitSound {
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
        
        // TODO: このカウントもGameSessionに含めてStore管理にする
        reloadingMotionDetecedCount += 1
        if reloadingMotionDetecedCount == 20 {
            soundPlayer.play(.targetAppearanceChange)
            arShootingLibHandler.changeTargetsAppearance(to: "taimeisan.jpg")
        }
    }
}
