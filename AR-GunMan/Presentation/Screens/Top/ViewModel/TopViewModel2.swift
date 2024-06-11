//
//  TopViewModel2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/6/24.
//

import RxSwift
import RxCocoa

final class TopViewModel2: ViewModelType {
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
            let iconChangingSoundPlayed: Observable<SoundType>
        }
        
        struct OutputToView {
            let startButtonImageName: Observable<String>
            let settingsButtonImageName: Observable<String>
            let howToPlayButtonImageName: Observable<String>
        }
    }
    
    class State {}

    private let useCase: TopUseCaseInterface
    private let navigator: TopNavigatorInterface
    private let soundPlayer: SoundPlayerInterface
    
    init(
        useCase: TopUseCaseInterface,
        navigator: TopNavigatorInterface,
        soundPlayer: SoundPlayerInterface
    ) {
        self.useCase = useCase
        self.navigator = navigator
        self.soundPlayer = soundPlayer
    }

    func transform(input: Input) -> Output {
        
        
        return Output(
            viewModelAction: Output.ViewModelAction(
                gameViewShowed: ,
                settingsViewShowed: ,
                tutorialViewShowed: ,
                iconChangingSoundPlayed:
            ),
            outputToView: Output.OutputToView(
                startButtonImageName: ,
                settingsButtonImageName: ,
                howToPlayButtonImageName:
            )
        )
    }
}
