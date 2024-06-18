//
//  TopPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

struct TopControllerInput {
    let viewDidAppear: Observable<Void>
    let startButtonTapped: Observable<Void>
    let settingsButtonTapped: Observable<Void>
    let howToPlayButtonTapped: Observable<Void>
}

struct TopViewModel2 {
    let isStartButtonIconSwitched: Observable<Bool>
    let isSettingsButtonIconSwitched: Observable<Bool>
    let isHowToPlayButtonIconSwitched: Observable<Bool>
}

protocol TopPresenterInterface {
    func transform(input: TopControllerInput) -> TopViewModel2
}

final class TopPresenter: TopPresenterInterface {
    private let replayNecessityCheckUseCase: ReplayNecessityCheckUseCaseInterface
    private let cameraPermissionCheckUseCase: CameraPermissionCheckUseCaseInterface
    private let buttonIconChangeUseCase: TopPageButtonIconChangeUseCaseInterface
    private let navigator: TopNavigatorInterface2
    private let disposeBag = DisposeBag()
    
    init(
        replayNecessityCheckUseCase: ReplayNecessityCheckUseCaseInterface,
        cameraPermissionCheckUseCase: CameraPermissionCheckUseCaseInterface,
        buttonIconChangeUseCase: TopPageButtonIconChangeUseCaseInterface,
        navigator: TopNavigatorInterface2
    ) {
        self.replayNecessityCheckUseCase = replayNecessityCheckUseCase
        self.cameraPermissionCheckUseCase = cameraPermissionCheckUseCase
        self.buttonIconChangeUseCase = buttonIconChangeUseCase
        self.navigator = navigator
    }
    
    func transform(input: TopControllerInput) -> TopViewModel2 {
        let startButtonIconChangeUseCaseOutput = buttonIconChangeUseCase
            .transform(input: .init(buttonTapped: input.startButtonTapped))
        
        let settingsButtonIconChangeUseCaseOutput = buttonIconChangeUseCase
            .transform(input: .init(buttonTapped: input.settingsButtonTapped))
        
        let howToPlayButtonIconChangeUseCaseOutput = buttonIconChangeUseCase
            .transform(input: .init(buttonTapped: input.howToPlayButtonTapped))
        
        let cameraPermissionCheckUseCaseOutput = cameraPermissionCheckUseCase
            .transform(input: .init(checkIsCameraAccessPermitted: startButtonIconChangeUseCaseOutput.buttonIconReverted))
        
        let replayNecessityCheckUseCaseOutput = replayNecessityCheckUseCase
            .transform(input: .init(checkNeedsReplay: input.viewDidAppear))
        
        disposeBag.insert {
            cameraPermissionCheckUseCaseOutput.showCameraPermissionDescriptionAlert
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showCameraPermissionDescriptionAlert()
                })
            Observable
                .merge(
                    replayNecessityCheckUseCaseOutput.showGameForReplay,
                    cameraPermissionCheckUseCaseOutput.showGame
                )
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showGame()
                })
            settingsButtonIconChangeUseCaseOutput.buttonIconReverted
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showSettings()
                })
            howToPlayButtonIconChangeUseCaseOutput.buttonIconReverted
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showTutorial()
                })
        }
        
        return TopViewModel2(
            isStartButtonIconSwitched: startButtonIconChangeUseCaseOutput.isButtonIconSwitched,
            isSettingsButtonIconSwitched: settingsButtonIconChangeUseCaseOutput.isButtonIconSwitched,
            isHowToPlayButtonIconSwitched: howToPlayButtonIconChangeUseCaseOutput.isButtonIconSwitched
        )
    }
}
