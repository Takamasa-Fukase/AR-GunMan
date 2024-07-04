//
//  TopPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

final class TopPresenter: PresenterType {
    struct ControllerEvents {
        let viewDidAppear: Observable<Void>
        let startButtonTapped: Observable<Void>
        let settingsButtonTapped: Observable<Void>
        let howToPlayButtonTapped: Observable<Void>
    }
    struct ViewModel {
        // TODO: ここでBoolに応じたImageNameに変換したい（systemImageとImageなのでそこを解消する必要あり）
        let isStartButtonIconSwitched: Driver<Bool>
        let isSettingsButtonIconSwitched: Driver<Bool>
        let isHowToPlayButtonIconSwitched: Driver<Bool>
    }
    
    private let replayNecessityCheckUseCase: ReplayNecessityCheckUseCaseInterface
    private let buttonIconChangeUseCase: TopPageButtonIconChangeUseCaseInterface
    private let cameraPermissionCheckUseCase: CameraPermissionCheckUseCaseInterface
    private let navigator: TopNavigatorInterface
    private let disposeBag = DisposeBag()
    
    init(
        replayNecessityCheckUseCase: ReplayNecessityCheckUseCaseInterface,
        buttonIconChangeUseCase: TopPageButtonIconChangeUseCaseInterface,
        cameraPermissionCheckUseCase: CameraPermissionCheckUseCaseInterface,
        navigator: TopNavigatorInterface
    ) {
        self.replayNecessityCheckUseCase = replayNecessityCheckUseCase
        self.buttonIconChangeUseCase = buttonIconChangeUseCase
        self.cameraPermissionCheckUseCase = cameraPermissionCheckUseCase
        self.navigator = navigator
    }
    
    func generateViewModel(from input: ControllerEvents) -> ViewModel {
        let replayNecessityCheckOutput = replayNecessityCheckUseCase
            .generateOutput(from: .init(checkNeedsReplay: input.viewDidAppear))
        let showGameForReplay = replayNecessityCheckOutput.showGameForReplay
        
        
        let startButtonIconChangeOutput = buttonIconChangeUseCase
            .generateOutput(from: .init(buttonTapped: input.startButtonTapped))
        let startButtonIconReverted = startButtonIconChangeOutput.buttonIconReverted
        let isStartButtonIconSwitched = startButtonIconChangeOutput.isButtonIconSwitched
        
        
        let settingsButtonIconChangeOutput = buttonIconChangeUseCase
            .generateOutput(from: .init(buttonTapped: input.settingsButtonTapped))
        let settingsButtonIconReverted = settingsButtonIconChangeOutput.buttonIconReverted
        let isSettingsButtonIconSwitched = settingsButtonIconChangeOutput.isButtonIconSwitched
        
        
        let howToPlayButtonIconChangeOutput = buttonIconChangeUseCase
            .generateOutput(from: .init(buttonTapped: input.howToPlayButtonTapped))
        let howToPlayButtonIconReverted = howToPlayButtonIconChangeOutput.buttonIconReverted
        let isHowToPlayButtonIconSwitched = howToPlayButtonIconChangeOutput.isButtonIconSwitched
        
        
        let cameraPermissionCheckOutput = cameraPermissionCheckUseCase
            .generateOutput(from: .init(checkIsCameraAccessPermitted: startButtonIconReverted))
        let showGame = cameraPermissionCheckOutput.showGame
        let showCameraPermissionDescriptionAlert = cameraPermissionCheckOutput.showCameraPermissionDescriptionAlert
        
        
        disposeBag.insert {
            // MARK: 画面遷移
            Observable
                .merge(
                    showGameForReplay,
                    showGame
                )
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showGame()
                })
            showCameraPermissionDescriptionAlert
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showCameraPermissionDescriptionAlert()
                })
            settingsButtonIconReverted
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showSettings()
                })
            howToPlayButtonIconReverted
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showTutorial()
                })
        }
        
        return ViewModel(
            isStartButtonIconSwitched: isStartButtonIconSwitched
                .asDriverOnErrorJustComplete(),
            isSettingsButtonIconSwitched: isSettingsButtonIconSwitched
                .asDriverOnErrorJustComplete(),
            isHowToPlayButtonIconSwitched: isHowToPlayButtonIconSwitched
                .asDriverOnErrorJustComplete()
        )
    }
}
