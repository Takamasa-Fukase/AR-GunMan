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

struct TopViewModel {
    // TODO: ここでBoolに応じたImageNameに変換したい（systemImageとImageなのでそこを解消する必要あり）
    let isStartButtonIconSwitched: Observable<Bool>
    let isSettingsButtonIconSwitched: Observable<Bool>
    let isHowToPlayButtonIconSwitched: Observable<Bool>
}

protocol TopPresenterInterface {
    func transform(input: TopControllerInput) -> TopViewModel
}

final class TopPresenter: TopPresenterInterface {
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
    
    func transform(input: TopControllerInput) -> TopViewModel {
        let replayNecessityCheckUseCaseOutput = replayNecessityCheckUseCase
            .transform(input: .init(checkNeedsReplay: input.viewDidAppear))
        
        let startButtonIconChangeUseCaseOutput = buttonIconChangeUseCase
            .transform(input: .init(buttonTapped: input.startButtonTapped))
        
        let settingsButtonIconChangeUseCaseOutput = buttonIconChangeUseCase
            .transform(input: .init(buttonTapped: input.settingsButtonTapped))
        
        let howToPlayButtonIconChangeUseCaseOutput = buttonIconChangeUseCase
            .transform(input: .init(buttonTapped: input.howToPlayButtonTapped))
        
        let cameraPermissionCheckUseCaseOutput = cameraPermissionCheckUseCase
            .transform(input: .init(checkIsCameraAccessPermitted: startButtonIconChangeUseCaseOutput.buttonIconReverted))
        
        disposeBag.insert {
            // MARK: Transitions
            Observable
                .merge(
                    replayNecessityCheckUseCaseOutput.showGameForReplay,
                    cameraPermissionCheckUseCaseOutput.showGame
                )
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showGame()
                })
            cameraPermissionCheckUseCaseOutput.showCameraPermissionDescriptionAlert
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showCameraPermissionDescriptionAlert()
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
        
        return TopViewModel(
            isStartButtonIconSwitched: startButtonIconChangeUseCaseOutput.isButtonIconSwitched,
            isSettingsButtonIconSwitched: settingsButtonIconChangeUseCaseOutput.isButtonIconSwitched,
            isHowToPlayButtonIconSwitched: howToPlayButtonIconChangeUseCaseOutput.isButtonIconSwitched
        )
    }
}
