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
        
        let startButtonIconChangeOutput = buttonIconChangeUseCase
            .generateOutput(from: .init(buttonTapped: input.startButtonTapped))
        
        let settingsButtonIconChangeOutput = buttonIconChangeUseCase
            .generateOutput(from: .init(buttonTapped: input.settingsButtonTapped))
        
        let howToPlayButtonIconChangeOutput = buttonIconChangeUseCase
            .generateOutput(from: .init(buttonTapped: input.howToPlayButtonTapped))
        
        let cameraPermissionCheckOutput = cameraPermissionCheckUseCase
            .generateOutput(from: .init(checkIsCameraAccessPermitted: startButtonIconChangeOutput.buttonIconReverted))
        
        disposeBag.insert {
            // MARK: 画面遷移
            Observable
                .merge(
                    replayNecessityCheckOutput.showGameForReplay,
                    cameraPermissionCheckOutput.showGame
                )
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showGame()
                })
            cameraPermissionCheckOutput.showCameraPermissionDescriptionAlert
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showCameraPermissionDescriptionAlert()
                })
            settingsButtonIconChangeOutput.buttonIconReverted
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showSettings()
                })
            howToPlayButtonIconChangeOutput.buttonIconReverted
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showTutorial()
                })
        }
        
        return ViewModel(
            isStartButtonIconSwitched: startButtonIconChangeOutput.isButtonIconSwitched
                .asDriverOnErrorJustComplete(),
            isSettingsButtonIconSwitched: settingsButtonIconChangeOutput.isButtonIconSwitched
                .asDriverOnErrorJustComplete(),
            isHowToPlayButtonIconSwitched: howToPlayButtonIconChangeOutput.isButtonIconSwitched
                .asDriverOnErrorJustComplete()
        )
    }
}
