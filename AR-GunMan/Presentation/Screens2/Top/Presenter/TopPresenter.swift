//
//  TopPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 18/6/24.
//

import RxSwift
import RxCocoa

final class TopPresenter {
    struct ControllerInput {
        let viewDidAppear: Observable<Void>
        let startButtonTapped: Observable<Void>
        let settingsButtonTapped: Observable<Void>
        let howToPlayButtonTapped: Observable<Void>
    }
    
    struct ViewModel {
        let isStartButtonIconSwitched: Observable<Bool>
        let isSettingsButtonIconSwitched: Observable<Bool>
        let isHowToPlayButtonIconSwitched: Observable<Bool>
    }
    
    private let replayNecessityCheckUseCase: ReplayNecessityCheckUseCase
    private let cameraPermissionCheckUseCase: CameraPermissionCheckUseCase
    private let buttonIconChangeUseCase: TopPageButtonIconChangeUseCase
    private let navigator: TopNavigatorInterface2
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(
        replayNecessityCheckUseCase: ReplayNecessityCheckUseCase,
        cameraPermissionCheckUseCase: CameraPermissionCheckUseCase,
        buttonIconChangeUseCase: TopPageButtonIconChangeUseCase,
        navigator: TopNavigatorInterface2,
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared
    ) {
        self.replayNecessityCheckUseCase = replayNecessityCheckUseCase
        self.cameraPermissionCheckUseCase = cameraPermissionCheckUseCase
        self.buttonIconChangeUseCase = buttonIconChangeUseCase
        self.navigator = navigator
        self.soundPlayer = soundPlayer
    }
    
    func transform(input: ControllerInput) -> ViewModel {
        let replayNecessityCheckUseCaseOutput = replayNecessityCheckUseCase
            .transform(input: .init(checkNeedsReplay: input.viewDidAppear))
        
        let startButtonIconChangeUseCaseOutput = buttonIconChangeUseCase
            .transform(input: .init(buttonTapped: input.startButtonTapped))
                
        let cameraPermissionCheckUseCaseOutput = cameraPermissionCheckUseCase
            .transform(input: .init(
                checkIsCameraAccessPermitted: startButtonIconChangeUseCaseOutput.buttonIconReverted)
            )
        
        Observable
            .merge(
                replayNecessityCheckUseCaseOutput.showGameForReplay,
                cameraPermissionCheckUseCaseOutput.showGame
            )
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showGame()
            })
            .disposed(by: disposeBag)
        
        cameraPermissionCheckUseCaseOutput.showCameraPermissionDescriptionAlert
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showCameraPermissionDescriptionAlert()
            })
            .disposed(by: disposeBag)
        
        let settingsButtonIconChangeUseCaseOutput = buttonIconChangeUseCase
            .transform(input: .init(buttonTapped: input.settingsButtonTapped))
        
        settingsButtonIconChangeUseCaseOutput.buttonIconReverted
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showSettings()
            })
            .disposed(by: disposeBag)

        let howToPlayButtonIconChangeUseCaseOutput = buttonIconChangeUseCase
            .transform(input: .init(buttonTapped: input.howToPlayButtonTapped))
        
        howToPlayButtonIconChangeUseCaseOutput.buttonIconReverted
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showTutorial()
            })
            .disposed(by: disposeBag)

        Observable
            .merge(
                startButtonIconChangeUseCaseOutput.playIconChangingSound,
                settingsButtonIconChangeUseCaseOutput.playIconChangingSound,
                howToPlayButtonIconChangeUseCaseOutput.playIconChangingSound
            )
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.soundPlayer.play($0)
            })
            .disposed(by: disposeBag)
        
        return ViewModel(
            isStartButtonIconSwitched: startButtonIconChangeUseCaseOutput.isButtonIconSwitched,
            isSettingsButtonIconSwitched: settingsButtonIconChangeUseCaseOutput.isButtonIconSwitched,
            isHowToPlayButtonIconSwitched: howToPlayButtonIconChangeUseCaseOutput.isButtonIconSwitched
        )
    }
}
