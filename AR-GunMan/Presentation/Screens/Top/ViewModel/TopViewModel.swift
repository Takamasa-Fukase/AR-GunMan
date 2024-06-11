//
//  TopViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/6/24.
//

import RxSwift
import RxCocoa

final class TopViewModel: ViewModelType {
    struct Input {
        let viewDidAppear: Observable<Void>
        let startButtonTapped: Observable<Void>
        let settingsButtonTapped: Observable<Void>
        let howToPlayButtonTapped: Observable<Void>
    }
    
    struct Output {
        let viewModelAction: ViewModelAction
        let outputToView: OutputToView
        
        struct ViewModelAction {
            let gameViewShowed: Observable<Void>
            let settingsViewShowed: Observable<Void>
            let tutorialViewShowed: Observable<Void>
            let cameraPermissionDescriptionAlertShowed: Observable<Void>
            let iconChangingSoundPlayed: Observable<SoundType>
            let needsReplayFlagIsSetToFalse: Observable<Void>
        }
        
        struct OutputToView {
            let isStartButtonIconSwitched: Observable<Bool>
            let isSettingsButtonIconSwitched: Observable<Bool>
            let isHowToPlayButtonIconSwitched: Observable<Bool>
        }
    }
    
    class State {}

    private let useCase: TopUseCaseInterface
    private let navigator: TopNavigatorInterface
    private let soundPlayer: SoundPlayerInterface

    // EventHandlers
    private let replayHandler: TopPageReplayHandler
    private let cameraPermissionHandler: CameraPermissionHandler
    private let buttonIconChangeHandler: TopPageButtonIconChangeHandler

    init(
        useCase: TopUseCaseInterface,
        navigator: TopNavigatorInterface,
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared,
        replayHandler: TopPageReplayHandler,
        cameraPermissionHandler: CameraPermissionHandler,
        buttonIconChangeHandler: TopPageButtonIconChangeHandler
    ) {
        self.useCase = useCase
        self.navigator = navigator
        self.soundPlayer = soundPlayer
        self.replayHandler = replayHandler
        self.cameraPermissionHandler = cameraPermissionHandler
        self.buttonIconChangeHandler = buttonIconChangeHandler
    }

    func transform(input: Input) -> Output {
        // MARK: - ViewModelAction
        let replayHandlerOutput = replayHandler
            .transform(input: .init(checkNeedsReplay: input.viewDidAppear))
        
        let needsReplayFlagIsSetToFalse = replayHandlerOutput.setNeedsReplayFlagToFalse
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.useCase.setNeedsReplay(false)
            })
        
        let startButtonIconChangeHandlerOutput = buttonIconChangeHandler
            .transform(input: .init(buttonTapped: input.startButtonTapped))
                
        let cameraPermissionHandlerOutput = cameraPermissionHandler
            .transform(input: .init(
                checkIsCameraAccessPermitted: startButtonIconChangeHandlerOutput.buttonIconReverted)
            )
        
        let gameViewShowed = Observable
            .merge(
                replayHandlerOutput.showGameForReplay,
                cameraPermissionHandlerOutput.showGame
            )
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showGame()
            })
        
        let cameraPermissionDescriptionAlertShowed = cameraPermissionHandlerOutput.showCameraPermissionDescriptionAlert
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showCameraPermissionDescriptionAlert()
            })
        
        let settingsButtonIconChangeHandlerOutput = buttonIconChangeHandler
            .transform(input: .init(buttonTapped: input.settingsButtonTapped))
        
        let settingsViewShowed = settingsButtonIconChangeHandlerOutput.buttonIconReverted
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showSettings()
            })
        
        let howToPlayButtonIconChangeHandlerOutput = buttonIconChangeHandler
            .transform(input: .init(buttonTapped: input.howToPlayButtonTapped))
        
        let tutorialViewShowed = howToPlayButtonIconChangeHandlerOutput.buttonIconReverted
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showTutorial()
            })

        let iconChangingSoundPlayed = Observable
            .merge(
                startButtonIconChangeHandlerOutput.playIconChangingSound,
                settingsButtonIconChangeHandlerOutput.playIconChangingSound,
                howToPlayButtonIconChangeHandlerOutput.playIconChangingSound
            )
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
        
        
        // MARK: - OutputToView
        let isStartButtonIconSwitched = startButtonIconChangeHandlerOutput.isButtonIconSwitched
        
        let isSettingsButtonIconSwitched = settingsButtonIconChangeHandlerOutput.isButtonIconSwitched
        
        let isHowToPlayButtonIconSwitched = howToPlayButtonIconChangeHandlerOutput.isButtonIconSwitched
        
        return Output(
            viewModelAction: Output.ViewModelAction(
                gameViewShowed: gameViewShowed,
                settingsViewShowed: settingsViewShowed,
                tutorialViewShowed: tutorialViewShowed,
                cameraPermissionDescriptionAlertShowed: cameraPermissionDescriptionAlertShowed,
                iconChangingSoundPlayed: iconChangingSoundPlayed,
                needsReplayFlagIsSetToFalse: needsReplayFlagIsSetToFalse
            ),
            outputToView: Output.OutputToView(
                isStartButtonIconSwitched: isStartButtonIconSwitched,
                isSettingsButtonIconSwitched: isSettingsButtonIconSwitched,
                isHowToPlayButtonIconSwitched: isHowToPlayButtonIconSwitched
            )
        )
    }
}
